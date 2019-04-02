#
# centos7-nodejs:nodejs
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-nodejs:nodejs"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-nodejs:nodejs-build AS nodejs-build-stage

# CentOS7-NodeJS from Scratch
FROM scratch AS nodejs

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="Node.js on CentOS7 with Systemd"

# COPY From build stage
COPY \
 --from=nodejs-build-stage / /

# Set Workdir
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

