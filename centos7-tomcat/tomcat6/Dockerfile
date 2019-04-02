#
# centos7-tomcat:tomcat6
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-tomcat:tomcat6"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg TCPKG_BASE=https://archive.apache.org/dist/tomcat"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg TCPKG_PATH=/tomcat-6/v6.0.53/bin/apache-tomcat-6.0.53.zip"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-tomcat:tomcat AS build-stage

# CentOS7-Tomcat6 from Scratch
FROM scratch AS centos7-tomcat6

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="Tomcat6 Server on CentOS7 with Systemd"

# Set Workdir
WORKDIR \
 /root

# COPY From build stage
COPY \
 --from=build-stage / /

# Reset Workdir
WORKDIR \
 /

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos7-tomcat6 --privileged" \
 docker.run.confirm-startup=""

