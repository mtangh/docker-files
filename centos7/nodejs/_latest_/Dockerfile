#
# centos7-nodejs
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# Build Image for Node.js on CentOS7 Minimal
FROM centos7:minimal-onbuild AS latest

# Node modules
ARG NODEJS_MODULES="grunt-cli gulp"

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# SetUp
RUN \
 set -x; \
 : "Install packages for nodejs" && { \
  yum -v -y update && \
  yum -v -y install nodejs npm && \
  yum -v -y clean all; \
 } && \
 : "Install node packages" && { \
  [ -z "${NODEJS_MODULES:-}" ] || { \
   npm -g install ${NODEJS_MODULES}; \
   npm -g cache clean --force; \
  } || :; \
  [ -x "/usr/bin/npm" ] && { \
   ln -sf /usr/bin/{npm,npm-g}; \
  } || :; \
 } && \
 : "Print node and npm version" && { \
  node -v && npm -v || :; \
 } && \
 : "Cleanup" && { \
  work_dir=$(pwd); cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf "${work_dir}" || :; \
 } && \
 : "Done.";

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


# Node.js on CentOS7 Minimal
FROM latest AS latest-onbuild

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# Labels
LABEL \
 name="Node.js on CentOS7 Minimal (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7-nodejs --privileged" \
 docker.run.confirm-startup=""

# ONBUILD: Additional Node modules
ONBUILD \
ARG NODEJS_MODULES=""

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: Copy contents
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -x; \
 : "ONBUILD: Install additional node modules" && { \
  [ -z "${NODEJS_MODULES:-}" ] || { \
   npm -g install ${NODEJS_MODULES} && \
   npm -g cache clean; \
  }; \
 }; \
 : "ONBUILD: Execute SetUp Script" && { \
  [ ! -e "./setup.sh" ] || { \
   /bin/bash ./setup.sh; \
  }; \
 }; \
 : "ONBUILD: Cleanup" && { \
  work_dir=$(pwd); cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf "${work_dir}" || :; \
 } && \
 : "Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

