# Keep in sync with version in frank-runner.properties. Detailed instructions can be found in CONTRIBUTING.md.
# Check whether java-orig files have changed in F!F and update custom code (java and java-orig files) accordingly
ARG FF_VERSION=9.0.0-20241226.042327
FROM docker.io/frankframework/frankframework:${FF_VERSION} as ff-base

# Copy dependencies
COPY --chown=tomcat lib/server/* /usr/local/tomcat/lib/
COPY --chown=tomcat lib/webapp/* /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/

# # Compile custom class
# FROM eclipse-temurin:17-jdk-jammy AS custom-code-builder

# # Copy dependencies
# COPY --from=ff-base /usr/local/tomcat/lib/ /usr/local/tomcat/lib/
# COPY --from=ff-base /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/ROOT

# # Copy custom class
# COPY src/main/java /tmp/java
# RUN mkdir /tmp/classes && \
#     javac \
#     /tmp/java/org/frankframework/parameters/Parameter.java \
#     -classpath "/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
#     -verbose -d /tmp/classes

# FROM ff-base

# Copy custom entrypoint script with added options
COPY --chown=tomcat docker/entrypoint.sh /scripts/entrypoint.sh

# TempFix TODO: Move this to the credentialprovider.properties
ENV credentialFactory.class=nl.nn.credentialprovider.PropertyFileCredentialFactory
ENV credentialFactory.map.properties=/opt/frank/resources/credentials.properties

# Set sensable defaults
ENV log.level=INFO
ENV zaakbrug.zds.timezone=UTC

# When deploying the "context.xml" should be copied to /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml
COPY --chown=tomcat src/main/webapp/META-INF/context.xml /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml

# Copy Frank!
COPY --chown=tomcat src/main/configurations/ /opt/frank/configurations/
COPY --chown=tomcat src/main/resources/ /opt/frank/resources/
COPY --chown=tomcat src/test/testtool/ /opt/frank/testtool/

# # Copy compiled custom class
# COPY --from=custom-code-builder --chown=tomcat /tmp/classes/ /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

# Check if Frank! is still healthy
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=60 \
	CMD curl --fail --silent http://localhost:8080/iaf/api/server/health || \
        (curl --silent http://localhost:8080/iaf/api/server/health && exit 1)
