/*
   Copyright 2018, 2019 Nationale-Nederlanden, 2020-2021 WeAreFrank!

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
package org.frankframework.configuration;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.Logger;

import org.frankframework.configuration.classloaders.IConfigurationClassLoader;
import org.frankframework.configuration.classloaders.WebAppClassLoader;
import org.frankframework.util.AppConstants;
import org.frankframework.util.ClassUtils;
import org.frankframework.util.LogUtil;
import org.frankframework.util.MessageKeeper.MessageKeeperLevel;
import org.frankframework.util.StringUtil;

/**
 * Loads a ClassLoader on a per Configuration basis. It is possible to specify the ClassLoader type and to make
 * ClassLoaders inherit each other. If no ClassLoader is specified the WebAppClassLoader is used, which will
 * first try to search for resources on the basepath and then the webapp and classpath.
 *
 * @author Niels Meijer
 *
 */
public class ClassLoaderManager {

	private static final Logger LOG = LogUtil.getLogger(ClassLoaderManager.class);
	private final AppConstants APP_CONSTANTS = AppConstants.getInstance();
	private final int MAX_CLASSLOADER_ITEMS = APP_CONSTANTS.getInt("classloader.items.max", 100);
	private final Map<String, ClassLoader> classLoaders = new TreeMap<>();
	private final ClassLoader classPathClassLoader = Thread.currentThread().getContextClassLoader();

	private IbisContext ibisContext;

	public ClassLoaderManager(IbisContext ibisContext) {
		this.ibisContext = ibisContext;
	}

	private ClassLoader createClassloader(String configurationName, String classLoaderType) throws ClassLoaderException {
		return createClassloader(configurationName, classLoaderType, classPathClassLoader);
	}

	private ClassLoader createClassloader(String configurationName, String classLoaderType, ClassLoader parentClassLoader) throws ClassLoaderException {
		//It is possible that no ClassLoader has been defined, use default ClassLoader
		if(classLoaderType == null || classLoaderType.isEmpty())
			throw new ClassLoaderException("classLoaderType cannot be empty");

		String className = classLoaderType;
		if(classLoaderType.indexOf(".") == -1)
			className = "org.frankframework.configuration.classloaders." + classLoaderType;

		LOG.debug("trying to create classloader of type["+className+"]");

		ClassLoader classLoader = null;
		try {
			Class<?> clas = ClassUtils.loadClass(className);
			Constructor<?> con = ClassUtils.getConstructorOnType(clas, new Class[] {ClassLoader.class});
			classLoader = (ClassLoader) con.newInstance(new Object[] {parentClassLoader});
		}
		catch (Exception e) {
			throw new ClassLoaderException("invalid classLoaderType ["+className+"]", e);
		}
		LOG.debug("successfully instantiated classloader ["+ClassUtils.nameOf(classLoader)+"] with parent classloader ["+ClassUtils.nameOf(parentClassLoader)+"]");

		//If the classLoader implements IClassLoader, configure it
		if(classLoader instanceof IConfigurationClassLoader) {
			IConfigurationClassLoader loader = (IConfigurationClassLoader) classLoader;

			String parentProperty = "configurations." + configurationName + ".";

			for(Method method: loader.getClass().getMethods()) {
				if(!method.getName().startsWith("set") || method.getParameterTypes().length != 1)
					continue;

				String setter = StringUtil.lcFirst(method.getName().substring(3));
				String value = APP_CONSTANTS.getProperty(parentProperty+setter);
				if(value == null)
					continue;

				//Only always grab the first value because we explicitly check method.getParameterTypes().length != 1
				Object castValue = getCastValue(method.getParameterTypes()[0], value);
				LOG.debug("trying to set property ["+parentProperty+setter+"] with value ["+value+"] of type ["+castValue.getClass().getCanonicalName()+"] on ["+ClassUtils.nameOf(loader)+"]");

				try {
					method.invoke(loader, castValue);
				} catch (Exception e) {
					throw new ClassLoaderException("error while calling method ["+setter+"] on classloader ["+ClassUtils.nameOf(loader)+"]", e);
				}
			}

			try {
				loader.configure(ibisContext, configurationName);
			}
			catch (ClassLoaderException ce) {
				String msg = "error configuring ClassLoader for configuration ["+configurationName+"]";
				switch(loader.getReportLevel()) {
					case DEBUG:
						LOG.debug(msg, ce);
						break;
					case INFO:
						ibisContext.log(msg, MessageKeeperLevel.INFO, ce);
						break;
					case WARN:
						ApplicationWarnings.add(LOG, msg, ce);
						break;
					case ERROR:
					default:
						throw ce;
				}

				//Break here, we cannot continue when there are ConfigurationExceptions!
				return null;
			}
			LOG.info("configured classloader ["+ClassUtils.nameOf(loader)+"]");
		}

		return classLoader;
	}

	private Object getCastValue(Class<?> class1, String value) {
		String className = class1.getName().toLowerCase();
		if("boolean".equals(className))
			return Boolean.parseBoolean(value);
		else if("int".equals(className) || "integer".equals(className))
			return Integer.parseInt(value);
		else
			return value;
	}

	private ClassLoader init(String configurationName, String classLoaderType) throws ClassLoaderException {
		return init(configurationName, classLoaderType, APP_CONSTANTS.getString("configurations." + configurationName + ".parentConfig", null));
	}

	private ClassLoader init(String configurationName, String classLoaderType, String parentConfig) throws ClassLoaderException {
		if(contains(configurationName))
			throw new ClassLoaderException("unable to add configuration with duplicate name ["+configurationName+"]");

		if(StringUtils.isEmpty(classLoaderType)) {
			classLoaderType = APP_CONSTANTS.getString("configurations." + configurationName + ".classLoaderType", "");
			if(StringUtils.isEmpty(classLoaderType)) {
				classLoaderType = WebAppClassLoader.class.getSimpleName();
			}
		}

		LOG.info("attempting to create new ClassLoader of type ["+classLoaderType+"] for configuration ["+configurationName+"]");

		ClassLoader classLoader;
		if(StringUtils.isNotEmpty(parentConfig)) {
			if(!contains(parentConfig))
				throw new ClassLoaderException("failed to locate parent configuration ["+parentConfig+"]");

			classLoader = createClassloader(configurationName, classLoaderType, get(parentConfig));
			LOG.debug("created a new classLoader ["+ClassUtils.nameOf(classLoader)+"] with parentConfig ["+parentConfig+"]");
		}
		else
			classLoader = createClassloader(configurationName, classLoaderType);

		if(classLoader == null) {
			//A databaseClassloader error occurred, cancel, break, abort (but don't throw a ConfigurationException!
			//If this is thrown, the ibis developer specifically did not want to throw an exception.
			return null;
		}

		classLoaders.put(configurationName, classLoader);
		if (classLoaders.size() > MAX_CLASSLOADER_ITEMS) {
			String msg = "Number of ClassLoader instances exceeds [" + MAX_CLASSLOADER_ITEMS + "]. Too many ClassLoader instances can cause an OutOfMemoryError";
			ApplicationWarnings.add(LOG, msg);
		}
		return classLoader;
	}

	/**
	 * Returns the ClassLoader for a specific configuration.
	 * @param configurationName to get the ClassLoader for
	 * @return ClassLoader or null on error
	 * @throws ClassLoaderException when a ClassLoader failed to initialize
	 */
	public ClassLoader get(String configurationName) throws ClassLoaderException {
		return get(configurationName, null);
	}

	/**
	 * Returns the ClassLoader for a specific configuration. Creates the ClassLoader if it doesn't exist yet.
	 * @param configurationName to get the ClassLoader for
	 * @param classLoaderType null or type of ClassLoader to load
	 * @return ClassLoader or null on error
	 * @throws ClassLoaderException when a ClassLoader failed to initialize
	 */
	public ClassLoader get(String configurationName, String classLoaderType) throws ClassLoaderException {
		if(ibisContext == null) {
			throw new IllegalStateException("shutting down");
		}

		LOG.debug("get configuration ClassLoader ["+configurationName+"]");
		ClassLoader classLoader = classLoaders.get(configurationName);
		if (classLoader == null) {
			classLoader = init(configurationName, classLoaderType);
		}
		return classLoader;
	}

	/**
	 * Reloads a configuration if it exists. Does not create a new one!
	 * See {@link #reload(ClassLoader)} for more information
	 */
	public void reload(String configurationName) throws ClassLoaderException {
		if(ibisContext == null) {
			throw new IllegalStateException("shutting down");
		}

		ClassLoader classLoader = classLoaders.get(configurationName);
		if (classLoader != null) {
			reload(classLoader);
		} else {
			LOG.warn("classloader for configuration ["+configurationName+"] not found, ignoring reload");
		}
	}

	/**
	 * Reuse class loader as it is difficult to have all
	 * references to the class loader removed (see also
	 * http://zeroturnaround.com/rebellabs/rjc201/).
	 * Create a heapdump after an unload and garbage collect and
	 * view the references to the instances of the root class
	 * loader class (BasePathClassLoader when a base path is
	 * used).
	 */
	public void reload(ClassLoader classLoader) throws ClassLoaderException {
		if(ibisContext == null) {
			throw new IllegalStateException("shutting down");
		}

		if (classLoader == null)
			throw new ClassLoaderException("classloader cannot be null");

		if (classLoader instanceof IConfigurationClassLoader) {
			((IConfigurationClassLoader) classLoader).reload();
		} else {
			LOG.warn("classloader ["+ClassUtils.nameOf(classLoader)+"] does not derive from IConfigurationClassLoader, ignoring reload");
		}
	}

	public boolean contains(String currentConfigurationName) {
		return classLoaders.containsKey(currentConfigurationName);
	}

	/**
	 * Removes all created ClassLoaders
	 */
	public void shutdown() {
		ibisContext = null; //Remove ibisContext reference

		for (Iterator<String> iterator = classLoaders.keySet().iterator(); iterator.hasNext();) {
			String configurationClassLoader = iterator.next();
			ClassLoader classLoader = classLoaders.get(configurationClassLoader);
			if(classLoader instanceof IConfigurationClassLoader) {
				((IConfigurationClassLoader) classLoader).destroy();
			} else {
				LOG.warn("classloader ["+ClassUtils.nameOf(classLoader)+"] does not derive from IConfigurationClassLoader, ignoring destroy");
			}
			iterator.remove();
			LOG.info("removed classloader ["+ClassUtils.nameOf(classLoader)+"]");
		}
		if(classLoaders.size() > 0) {
			LOG.warn("not all ClassLoaders where removed. Removing references to remaining classloaders "+classLoaders);

			classLoaders.clear();
		}
	}
}
