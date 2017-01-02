#
# centos7-systemd:java8
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:java8"
#@  DOCKER_BUILDOPTS="--build-arg jdk_version=8u112-b15"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-systemd:java-onbuild

# Maintainer
MAINTAINER MT

# Labels for run
LABEL \
 docker.run.options="-d -P -h java8-machine --privileged" \
 docker.run.confirm-startup=""

