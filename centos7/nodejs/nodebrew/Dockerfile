#
# centos7-nodejs:nodebrew
#
#@  DOCKER_IMAGEPATH="centos7-nodejs:nodebrew"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS="${DOCKER_IMAGEPATH}:${DOCKER_IMAGE_VER}"
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}:${DOCKER_IMAGE_VER}"
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}:latest"
#

# Node.js version
ARG NODEJS_VER="stable"

# Nodebrew root dir.
ARG NODEBREW_ROOT="/opt/nodebrew"

# Nodebrew URL
ARG NODEBREW_URL="http://git.io/nodebrew"

# Build Image for Node.js on CentOS7 Minimal
FROM centos7:minimal

# Node.js version
ARG NODEJS_VER

# Nodebrew root dir.
ARG NODEBREW_ROOT

# Nodebrew URL
ARG NODEBREW_URL

# Node.js Version
ENV NODEJS_VER="${NODEJS_VER:-stable}"

# Nodebrew ROOT
ENV NODEBREW_ROOT="${NODEBREW_ROOT:-/opt/nodebrew}"

# Nodebrew URL
ENV NODEBREW_URL="${NODEBREW_URL:-http://git.io/nodebrew}"

# Path
ENV PATH="${PATH}${NODEBREW_ROOT:+:${NODEBREW_ROOT}/current/bin}"

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY shell scripts to Workdir
COPY nodejs-*.sh ./

# SetUp
RUN \
 set -ux; /bin/bash -ux -o errtrace -o functrace -o pipefail ./nodejs-nodebrew.sh
 
# Set Workdir
WORKDIR /.onbuild

# COPY shell scripts to Workdir
COPY nodejs-node_modules.sh ./onbuild.sh

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Node.js (${NODEJS_VER}) on CentOS7 Minimal" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7-nodejs-${NODEJS_VER} --privileged" \
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
