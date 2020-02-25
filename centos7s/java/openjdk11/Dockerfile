#
# centos7s-java-openjdk:11
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7s-java-openjdk:11"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# Java-OpenJDK Version
ARG JAVA_OPENJDK_VER=11

# Build-Stage
FROM centos7s-java-openjdk:0

# OpenJDK Version
ARG JAVA_OPENJDK_VER

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Java-OpenJDK ${JAVA_OPENJDK_VER} on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-java-openjdk_${JAVA_OPENJDK_VER} --privileged" \
 docker.run.confirm-startup=""

