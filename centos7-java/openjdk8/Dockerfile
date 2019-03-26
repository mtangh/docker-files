#
# centos7-java:openjdk8
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-java:openjdk8"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-java:openjdk

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="Java-JDK8 on CentOS7 with Systemd"

# Labels for run
LABEL \
 docker.run.options="-d -P -h javavm-openjdk8 --privileged" \
 docker.run.confirm-startup=""

