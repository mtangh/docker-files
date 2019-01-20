#
# centos7-tomcat:tomcat6
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-tomcat:tomcat6"
#@  DOCKER_BUILDOPTS="--build-arg TC_URL_PATH=/tomcat-6/v6.0.53/bin/apache-tomcat-6.0.53.zip"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-tomcat:tomcat

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Tomcat6 Server on CentOS7 with Systemd"

# Labels for run
LABEL \
 docker.run.options="-d -P -h tomcat6 --privileged" \
 docker.run.confirm-startup=""

# Publish a container's port(s) to the host
EXPOSE 8080 8443

