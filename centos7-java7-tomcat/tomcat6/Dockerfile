#
# centos7-java7-tomcat:tomcat6
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-java7-tomcat:tomcat6"
#@  DOCKER_BUILDOPTS="--build-arg TC_URL_PATH=/tomcat-6/v6.0.48/bin/apache-tomcat-6.0.48.zip"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-java7-tomcat:tomcat

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Tomcat6 Server on CentOS7 with Java7"

# Labels for run
LABEL \
 docker.run.options="-d -P -h tomcat6 --privileged" \
 docker.run.confirm-startup=""

