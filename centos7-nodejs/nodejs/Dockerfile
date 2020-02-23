#
# centos7-nodejs:nodejs
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7-nodejs:nodejs"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="Node.js on CentOS7 with Systemd"

# Work dir
ARG \
 WORKDIR=/tmp/workdir

# Set Workdir
WORKDIR \
 ${WORKDIR}

# Nodebrew
ARG \
 NODEBREW_URL=http://git.io/nodebrew
ARG \
 NODEBREW_ROOT=/opt/nodebrew

# Node version
ARG \
 NODE_VERSION=stable

# Node modules
ARG \
 DEFAULT_NODE_MODULES="bower grunt-cli gulp"

# SetUp
RUN \
 set -x; \
 : "Install packages for nodejs" && { \
  yum -v -y update && \
  yum -v -y install gcc-c++ perl && \
  yum -v -y clean all && \
  rm -rf /var/cache/yum/*; \
 } && \
 : "SetUp Nodebrew" && { \
  export NODEBREW_ROOT="${NODEBREW_ROOT:-/opt/nodebrew}"; \
  export PATH="$PATH:$NODEBREW_ROOT/current/bin"; \
  curl -sL "$NODEBREW_URL" |perl - setup && \
  nodebrew install-binary stable && \
  nodebrew use stable && \
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
 } && \
 : "SetUp /etc/profile.d/nodebrew.sh" && { \
  : && { \
   echo "# nodebrew.sh" && \
   echo "export NODEBREW_ROOT=$NODEBREW_ROOT" && \
   echo 'export PATH="$PATH:$NODEBREW_ROOT/current/bin"' && \
   echo ""; \
  } 1>/etc/profile.d/nodebrew.sh && \
  chown root:root /etc/profile.d/nodebrew.sh && \
  chmod 0755 /etc/profile.d/nodebrew.sh; \
 } && \
 : "Print node and npm version" && { \
  node -v && npm -v || :; \
 }; \
 : "Install node packages" && { \
  [ -z "${DEFAULT_NODE_MODULES}" ] || { \
   npm -g install ${DEFAULT_NODE_MODULES}; \
   npm -g cache clean; \
  } && \
  rm -rf /tmp/npm* || :; \
 } && \
 : "Cleanup" && { \
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done || :; \
  yum -v -y clean all && rm -rf /var/cache/yum/*; \
  [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
   cd /; rm -rf "${WORKDIR}"; } || :; \
 } 2>/dev/null; \
 echo;

# Reset Work dir
WORKDIR /

#-
#- Begin ONBUILDs
#-

# ONBUILD: Work dir
ONBUILD \
ARG \
 WORKDIR="/tmp/workdir"

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR \
 ${WORKDIR}

# ONBUILD: Additional Node modules
ONBUILD \
ARG \
 NODE_MODULES=""

# ONBUILD: Copy contents
ONBUILD \
COPY \
 * "${WORKDIR}/"

# ONBUILD: Install node moduless
ONBUILD \
RUN \
 set -x; \
 : "ONBUILD: Install additional node modules" && { \
  [ -z "${NODE_MODULES}" ] || { \
   npm -g install ${NODE_MODULES} && \
   npm -g cache clean; \
  }; \
 }; \
 : "ONBUILD: Execute SetUp Script" && { \
  [ ! -e "./setup.sh" ] || { \
   /bin/bash ./setup.sh; \
  }; \
 }; \
 : "ONBUILD: Cleanup" && { \
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done || :; \
  yum -v -y clean all && rm -rf /var/cache/yum/*; \
  [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
   cd /; rm -rf "${WORKDIR}"; } || :; \
 } 2>/dev/null; \
 echo;

# ONBUILD: Reset Work dir
ONBUILD \
WORKDIR /

#-
#- End of ONBUILDs
#-

# Labels for run
LABEL \
 docker.run.options="-d -P -h nodejs-server --privileged" \
 docker.run.confirm-startup=""

