#
# centos7s-java-openjdk
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# Java-OpenJDK Version
ARG JAVA_OPENJDK_VER=7

# Build-Stage
FROM centos7s-java-openjdk:0 AS ${JAVA_OPENJDK_VER}

# OpenJDK Version
ARG JAVA_OPENJDK_VER

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Java-OpenJDK ${JAVA_OPENJDK_VER} on CentOS7 with Systemd"
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-java-openjdk_${JAVA_OPENJDK_VER} --privileged" \
 docker.run.confirm-startup=""

