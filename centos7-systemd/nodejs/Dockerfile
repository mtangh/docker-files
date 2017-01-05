#
# centos7-systemd:nodejs
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:nodejs"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Node.js on CentOS7 with Systemd"

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

# Install packages for nodejs
RUN \
 set -x; \
 yum -v -y update && \
 yum -v -y install gcc-c++ perl && \
 yum -v -y clean all

# Install nodebrew, and node
ARG \
 NODEBREW_URL=http://git.io/nodebrew
ARG \
 NODEBREW_ROOT=/opt/nodebrew
ARG \
 NODE_VERSION=stable
RUN \
 set -x; \
 export NODEBREW_ROOT="${NODEBREW_ROOT:-/opt/nodebrew}"; \
 export PATH="$PATH:$NODEBREW_ROOT/current/bin"; \
 curl -L "$NODEBREW_URL" |perl - setup && \
 nodebrew install-binary stable && \
 nodebrew use stable && { \
  for item in "${NODEBREW_ROOT}/current/"{bin,lib}/*; \
  do \
   dest="${item##*$NODEBREW_ROOT/current/}"; \
   [ -x "$item" ] || continue; \
   [ -n "${dest%/*}" -a ! -d "/usr/local/${dest%/*}" ] && { \
    mkdir -p "/usr/local/${dest%/*}"; \
   }; \
   [ -n "$dest" -a -d "/usr/local/$dest" ] && { \
    rm -rf "/usr/local/$dest"; \
   }; \
   ln -sf "$item" "/usr/local/$dest"; \
  done; \
  [ ! -d "${NODEBREW_ROOT}/" ] || { \
   chown -R "root:root" "${NODEBREW_ROOT}/" || :; \
  }; \
  [ ! -x "/usr/local/bin/npm" ] || { \
   ln -sf /usr/local/bin/{npm,npm-g} || :; \
  }; \
 } && { \
  echo "# nodebrew.sh" && \
  echo "export NODEBREW_ROOT=$NODEBREW_ROOT" && \
  echo 'export PATH="$PATH:$NODEBREW_ROOT/current/bin"' && \
  echo ""; \
 } 1>/etc/profile.d/nodebrew.sh && \
 chown root:root /etc/profile.d/nodebrew.sh && \
 chmod 0755 /etc/profile.d/nodebrew.sh && \
 node -v && npm -v

# Install node packages
ARG \
 NODE_MODULES="bower grunt-cli gulp"
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
 docker.run.options="-d -P -h nodejs-server --privileged" \
 docker.run.confirm-startup=""

