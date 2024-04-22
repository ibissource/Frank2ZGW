/*
   Copyright 2021 WeAreFrank!

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
package org.frankframework.mongodb;

import java.util.List;
import java.util.Properties;

import javax.naming.NamingException;

import org.springframework.jndi.JndiLocatorSupport;

import com.mongodb.client.MongoClient;

public interface IMongoClientFactory {

	/**
	 * Look up a MongoClient from the JNDI
	 */
	public MongoClient getMongoClient(String dataSourceName) throws NamingException;

	/**
	 * Set the JNDI environment to use for JNDI lookups.
	 * <p>Uses a Spring JndiTemplate with the given environment settings.
	 * @see JndiLocatorSupport#setJndiTemplate
	 */
	public MongoClient getMongoClient(String dataSourceName, Properties jndiEnvironment) throws NamingException;

	/**
	 * Return all known/registered MongoClients
	 */
	public List<String> getMongoClients();
}
