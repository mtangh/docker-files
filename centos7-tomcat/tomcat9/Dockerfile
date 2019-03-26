#
# centos7-tomcat:tomcat9
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-tomcat:tomcat9"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg TCPKG_BASE=https://archive.apache.org/dist/tomcat"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg TCPKG_PATH=/tomcat-9/v9.0.16/bin/apache-tomcat-9.0.16.zip"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-tomcat:tomcat AS build-stage

# CentOS7-Tomcat9 from Scratch
FROM scratch AS centos7-tomcat9-stage

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="Tomcat9 Server on CentOS7 with Systemd"

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
 docker.run.options="-d -P -h centos7-tomcat9 --privileged" \
 docker.run.confirm-startup=""

