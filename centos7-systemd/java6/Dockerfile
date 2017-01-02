#
# centos7-systemd:java6
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:java6"
#@  DOCKER_BUILDOPTS="--build-arg jdk_version=6u45-b06 --build-arg jdk_file_type=bin"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-systemd:java-onbuild

# Maintainer
MAINTAINER MT

# Labels for run
LABEL \
 docker.run.options="-d -P -h java6-machine --privileged" \
 docker.run.confirm-startup=""

