#
# centos7-systemd_with-ssh
#
#@  DOCKER_IMAGEPATH="centos7-systemd_with-ssh"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS="${DOCKER_IMAGEPATH}:${DOCKER_IMAGE_VER}"
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#

# Logrotate
ARG LOGROTATION="YES"

# Enable SUDO
ARG ENABLE_SUDO="YES"

# SSH Login
ARG ENABLE_SSHD="YES"

# Image from
FROM centos7:systemd-onbuild

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS 7 with Systemd and SSHd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7-systemd_with-ssh --privileged --expose=22" \
 docker.run.confirm-startup=""

