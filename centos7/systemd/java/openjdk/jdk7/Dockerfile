#
# centos7s-java:openjdk7
#
#@  DOCKER_IMAGEPATH="centos7-systemd-java:openjdk0"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS=""
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}-${DOCKER_IMAGE_VER}"
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}"
#

# Java-OpenJDK Version
ARG JAVA_OPENJDK_VER=7

# Build-Stage
FROM centos7s-java:openjdk0

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
 docker.run.options="-d -P -h centos7-systemd-java_openjdk${JAVA_OPENJDK_VER} --privileged" \
 docker.run.confirm-startup=""

