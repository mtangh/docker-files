#
# centos6-upstart:sshd
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-upstart:sshd"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos6-upstart

# Labels
LABEL \
 name="SSHd on CentOS6 with upstart" \
 maintainer="MT"

# Reset Work dir
WORKDIR /

#-
#- Begin ONBUILDs
#-

# Work dir
ONBUILD \
ARG \
 WORKDIR="/tmp/workdir"
ONBUILD \
WORKDIR \
 ${WORKDIR}

# Copy contents
ONBUILD \
COPY \
 * "${WORKDIR}/"

# Setup
ONBUILD \
RUN \
 set -ux; \
 : "ONBUILD: Setup" && { \
  { [ ! -e "./setup.tgz" ] || tar -zxvf "./setup.tgz"; } && \
  { [ ! -e "./setup.sh" ] || /bin/bash -ux ./setup.sh; } && \
  echo "OK"; \
 }; \
 : "ONBUILD: Cleanup" && { \
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done || :; \
  [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
   cd /; rm -rf "${WORKDIR}"; } || :; \
 } 2>/dev/null || :; \
 echo;

# Reset Work dir
ONBUILD \
WORKDIR /

#-
#- End of ONBUILDs
#-

# Labels for run
LABEL \
 docker.run.options="-d -P -h c6-sshd-server --privileged" \
 docker.run.confirm-startup=""

