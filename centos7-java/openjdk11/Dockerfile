#
# centos7-java:openjdk11
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-java:openjdk11"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-java:openjdk AS build-stage

# Target stage
FROM scratch AS centos7-openjdk11-stage

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="Java-JDK11 on CentOS7 with Systemd"

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
 docker.run.options="-d -P -h javavm-openjdk11 --privileged" \
 docker.run.confirm-startup=""

