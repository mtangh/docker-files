#
# centos7-tomcat:tomcat8
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7-tomcat:tomcat8"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg TCPKG_BASE=https://archive.apache.org/dist/tomcat"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg TCPKG_PATH=/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.zip"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-tomcat:tomcat AS build-stage

# CentOS7-Tomcat8 from Scratch
FROM scratch AS centos7-tomcat8

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="Tomcat8 Server on CentOS7 with Systemd"

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
 docker.run.options="-d -P -h centos7-tomcat8 --privileged" \
 docker.run.confirm-startup=""

