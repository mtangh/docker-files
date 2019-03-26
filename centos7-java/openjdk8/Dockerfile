#
# centos7-java:openjdk8
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-java:openjdk8"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-java:openjdk AS build-stage

# Target stage
FROM scratch AS centos7-openjdk8-stage

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="Java-JDK8 on CentOS7 with Systemd"

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
 docker.run.options="-d -P -h javavm-openjdk8 --privileged" \
 docker.run.confirm-startup=""

