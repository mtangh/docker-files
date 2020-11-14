#
# centos7s-nodejs
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#

# Node.js version
ARG NODEJS_VER="stable"

# Nodebrew root dir.
ARG NODEBREW_ROOT="/opt/nodebrew"

# Build Image for Node.js on CentOS7 with Systemd
FROM centos7s-with-ssh:latest AS stable

# Node.js version
ARG NODEJS_VER

# Nodebrew root dir.
ARG NODEBREW_ROOT

# Nodebrew URL
ARG NODEBREW_URL="http://git.io/nodebrew"

# Node modules
ARG NODEJS_MODULES="grunt-cli gulp"

# Node.js Version
ENV NODEJS_VER="${NODEJS_VER:-stable}"

# Nodebrew ROOT
ENV NODEBREW_ROOT="${NODEBREW_ROOT:-/opt/nodebrew}"

# Path
ENV PATH="${PATH}${NODEBREW_ROOT:+:${NODEBREW_ROOT}/current/bin}"

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# SetUp
RUN \
 set -ux; \
 work_dir=$(pwd); \
 [ -n "${NODEJS_VER:-}" ] || { \
  echo "'NODEJS_VER' is not set." 1>&2; \
  exit 1; }; \
 [ -n "${NODEBREW_ROOT:-}" ] || { \
  echo "'NODEBREW_ROOT' is not set." 1>&2; \
  exit 1; }; \
 : "Install packages for nodejs" && { \
  yum -v -y update && \
  yum -v -y install gcc-c++ perl which && \
  yum -v -y clean all; \
 } && \
 : "SetUp Nodebrew" && { \
  [ -n "${NODEBREW_URL:-}" ] && \
  nodebrew_url="${NODEBREW_URL}" || \
  nodebrew_url="http://git.io/nodebrew"; \
  export NODEBREW_ROOT; \
  export PATH="${PATH}:${NODEBREW_ROOT}/current/bin"; \
  curl -sL "${NODEBREW_URL}" |perl - setup && \
  nodebrew install-binary "${NODEJS_VER}" && \
  nodebrew use "${NODEJS_VER}" && \
  for item in "${NODEBREW_ROOT}/current/"{bin,lib}/*; \
  do \
   dest="${item##*${NODEBREW_ROOT}/current/}"; \
   [ -x "${item}" ] || continue; \
   [ -n "${dest%/*}" -a ! -d "/usr/local/${dest%/*}" ] && { \
    mkdir -p "/usr/local/${dest%/*}"; }; \
   [ -n "${dest}" -a -d "/usr/local/${dest}" ] && { \
    rm -rf "/usr/local/${dest}"; }; \
   ln -sf "${item}" "/usr/local/${dest}"; \
  done; \
  [ -d "${NODEBREW_ROOT}/" ] && { \
   chown -R "root:root" "${NODEBREW_ROOT}/"; \
  } || :; \
  [ -x "/usr/local/bin/npm" ] && { \
   ln -sf /usr/local/bin/{npm,npm-g}; \
  } || :; \
 } && \
 : "Install node packages" && { \
  [ -z "${NODEJS_MODULES:-}" ] || { \
   npm -g install ${NODEJS_MODULES}; \
   npm -g cache clean --force; \
  }; \
 } && \
 : "Print node and npm version" && { \
  node -v && npm -v || :; \
 } && \
 : "Remove YUM packages" && { \
  yum -v -y remove gcc-c++ && { \
   pkg_leaves=$(echo $(package-cleanup --leaves)); \
   [ -n "${pkg_leaves}" ] && \
   yum -v -y remove ${pkg_leaves} || :; \
  } && \
  yum -v -y update && \
  yum -v -y clean all; \
 } && \
 : "YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "Done.";

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Node.js (${NODEJS_VER}) on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-nodejs-${NODEJS_VER} --privileged" \
 docker.run.confirm-startup=""


# Node.js on CentOS7 with Systemd
FROM stable AS stable-onbuild

# Node.js version
ARG NODEJS_VER

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# Labels
LABEL \
 name="Node.js (${NODEJS_VER}) on CentOS7 with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-nodejs-${NODEJS_VER} --privileged" \
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
 set -ux; \
 work_dir=$(pwd); \
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
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

