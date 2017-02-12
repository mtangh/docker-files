#
# centos7-java7-tomcat:tomcat8
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-java7-tomcat:tomcat8"
#@  DOCKER_BUILDOPTS="--build-arg TC_URL_PATH=/tomcat-8/v8.5.11/bin/apache-tomcat-8.5.11.zip"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-java7-tomcat:tomcat

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Tomcat8 Server on CentOS7 with Java7"

# Labels for run
LABEL \
 docker.run.options="-d -P -h tomcat8 --privileged" \
 docker.run.confirm-startup=""

