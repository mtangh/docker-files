#
# centos7-openjdk7-tomcat:tomcat7
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-openjdk7-tomcat:tomcat7"
#@  DOCKER_BUILDOPTS="--build-arg TC_URL_PATH=/tomcat-7/v7.0.92/bin/apache-tomcat-7.0.92.zip"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-openjdk7-tomcat:tomcat

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Tomcat7 Server on CentOS7 with Systemd"

# Labels for run
LABEL \
 docker.run.options="-d -P -h co7oj7-tomcat7 --privileged" \
 docker.run.confirm-startup=""

# Publish a container's port(s) to the host
EXPOSE 8080 8443

