#
# centos7-tomcat:tomcat8
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-tomcat:tomcat8"
#@  DOCKER_BUILDOPTS="--build-arg TC_URL_PATH=/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.zip"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-tomcat:tomcat

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Tomcat8 Server on CentOS7 with Systemd"

# Labels for run
LABEL \
 docker.run.options="-d -P -h tomcat8 --privileged" \
 docker.run.confirm-startup=""

# Publish a container's port(s) to the host
EXPOSE 8080 8443

