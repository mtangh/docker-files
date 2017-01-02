#
# centos6-upstart:nodejs
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-upstart:nodejs"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos6-upstart

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Node.js on CentOS6 with Upstart"

# Node packages
ONBUILD \
ARG \
 NODE_PACKAGES=""

# Install packages
ONBUILD \
RUN \
 set -x; \
 [ -z "$NODE_PACKAGES" ] || { \
  npm -g install $NODE_PACKAGES && \
  npm -g cache clean; \
 };

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 ${WORKDIR}

# Install packages
RUN \
 set -x; \
 yum -y update && \
 yum -y install which && \
 yum -y clean all

# Install packages
ARG \
 NODE_VERSION=v6.9.2
ARG \
 NODE_PACKAGE_NAME=node-${NODE_VERSION}-linux-x64
ARG \
 NODE_URL=https://nodejs.org/dist/${NODE_VERSION}/${NODE_PACKAGE_NAME}.tar.xz
ARG \
 NODE_INSTALL_DIR=/usr/local
COPY \
 * ${WORKDIR}/
RUN \
 set -x; \
 [ -e "./${NODE_PACKAGE_NAME}.tar.xz" ] || { \
  curl -sL -o "./${NODE_PACKAGE_NAME}.tar.xz" "${NODE_URL}"; \
 } && \
 xz -cdv "./${NODE_PACKAGE_NAME}.tar.xz" |tar -xvf - && \
 ( cd "./${NODE_PACKAGE_NAME}/" && \
   for dir in $(ls -1 2>/dev/null); \
   do \
    [ -d "./${dir}" ] && \
    cp -rf "./${dir}/"* "${NODE_INSTALL_DIR}/${dir}/"; \
   done; \
   export N_PREFIX="${NODE_INSTALL_DIR}" && \
   export PATH="${NODE_INSTALL_DIR}/bin:${PATH}" && \
   npm -g install n; npm -g cache clean)

# Install packages
ARG \
 NODE_MODULES="gulp nodemon eslint"
RUN \
 set -x; \
 [ -z "${NODE_MODULES}" ] || { \
  npm -g install ${NODE_MODULES}; \
  npm -g cache clean; \
 }; \
 rm -rf /tmp/npm*;

# Reset Work dir
WORKDIR /

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in {,/root,/tmp}/*.log; do rm -f "$log"; done; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && rm -rf "${WORKDIR}" || :

# Labels for run
LABEL \
 docker.run.options="-d -P -h nodejs-server" \
 docker.run.confirm-startup=""

