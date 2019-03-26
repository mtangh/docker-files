#
# centos7-systemd:without-ssh
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:without-ssh"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg without_ssh=yes"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg without_logrotate=yes"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="CentOS 7 without SSH" \
 vendor="UGOOLE.ORG" \
 license=""

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos7-without-ssh --privileged" \
 docker.run.confirm-startup=""

