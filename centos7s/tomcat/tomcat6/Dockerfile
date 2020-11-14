#
# centos7-tomcat:tomcat6
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7-tomcat:tomcat6"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# JDK Version
ARG JDKVERSION="6"

# Tomcat package URL
ARG TCPKG_BASE="https://archive.apache.org/dist/tomcat"
ARG TCPKG_PATH="/tomcat-6/v6.0.53/bin/apache-tomcat-6.0.53.zip"

#
FROM centos7-tomcat:template AS build-stage

# CentOS7-Tomcat6 from Scratch
FROM centos7s-java-openjdk:${JDKVERSION} AS centos7-tomcat6

# Set Workdir
WORKDIR /root

# COPY From build stage
COPY --from=build-stage / /

# Reset Workdir
WORKDIR /

# Labels for run
LABEL \
 name="Tomcat6 Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7-tomcat6 --privileged" \
 docker.run.confirm-startup=""

