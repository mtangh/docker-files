#
# centos7-nodejs
#
#@  DOCKER_IMAGEPATH="centos7-nodejs"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS="${DOCKER_IMAGEPATH}:${DOCKER_IMAGE_VER}"
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}:${DOCKER_IMAGE_VER}"
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}:latest"
#

# Extra RPM Packages
ARG ONBUILD_RPM_PACKAGES="nodejs npm"

# OnBuild Script
ARG ONBUILD_SHELL_SCRIPT="nodejs-node_modules.sh"

# Build Image for Node.js on CentOS7 Minimal
FROM centos7:minimal-onbuild

# Set Workdir
WORKDIR /.onbuild

# COPY shell scripts to Workdir
COPY nodejs-node_modules.sh ./onbuild.sh

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Node.js on CentOS7 Minimal" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7-nodejs --privileged" \
 docker.run.confirm-startup=""

# Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; \
 : "ONBUILD: Run" && { \
  scrptdir="/.onbuild"; \
  /bin/bash -ux -o errtrace -o functrace -o pipefail "${scrptdir:-X}/onbuild.sh" || exit 1; \
  rm -rf "${scrptdir:-X}/" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /
