#
# almalinux9-init_with-ssh
#
#@  DOCKER_IMAGEPATH="almalinux9-init_with-ssh"
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
FROM almalinux9:init-onbuild

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux 9 with Init and SSHd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h almalinux9-init_with-ssh --privileged --expose=22" \
 org.ugoole.docker.run.confirm-startup=""

