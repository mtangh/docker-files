#
# centos7-java-oracle-jdk:8
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7-java-oracle-jdk:8"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# ORACLE JDK Version
ARG JAVA_JDK_VER=jdk8

# Java-ORACLE-JDK on CentOS7 with Systemd
FROM centos7-java-oracle-jdk:0 AS 8

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Java-ORACLE-JDK (${JAVA_JDK_VER}) on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h centos7s-java-oracle-${JAVA_JDK_VER} --privileged" \
 org.ugoole.docker.run.confirm-startup=""

