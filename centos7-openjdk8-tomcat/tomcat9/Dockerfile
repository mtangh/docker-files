#
# centos7-openjdk8-tomcat:tomcat9
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-openjdk8-tomcat:tomcat9"
#@  DOCKER_BUILDOPTS="--build-arg TC_URL_PATH=/tomcat-9/v9.0.14/bin/apache-tomcat-9.0.14.zip"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-openjdk8-tomcat:tomcat

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Tomcat9 Server on CentOS7 with Systemd"

# Labels for run
LABEL \
 docker.run.options="-d -P -h co7oj8-tomcat9 --privileged" \
 docker.run.confirm-startup=""

