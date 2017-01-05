#
# centos7-systemd:httpd-onbuild
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:httpd-onbuild"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-systemd:httpd

# Maintainer
MAINTAINER MT

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
 www/* ${WORKDIR}/

# Init
ONBUILD \
RUN \
 set -x; \
 for item in etc/{,sysconfig/}httpd etc/php.{ini,d}; \
 do \
  [ -n "${item%/*}" ] && \
  [ ! -e "/${item%/*}" ] && \
  mkdir -p "/${item%/*}"; \
  cp -rf "./${item}" "/${item}"; \
 done; \
 for item in $(ls -1 2>/dev/null); \
 do \
  [ "$item" != "etc" ] && \
  if [ -d "/var/www/${item}" ]; \
  then cp -rf "./${item}"/* "/var/www/${item}/"; \
  else cp -rf "./${item}" "/var/www/"; \
  fi; \
 done; \
 [ ! -e "./setup.sh" ] || { \
  bash ./setup.sh && rm -f ./setup.sh; \
 } && \
 /usr/sbin/httpd -t;

# Reset Work dir
ONBUILD \
WORKDIR /

# Cleanup
ONBUILD \
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in {,/root,/tmp}/*.log; do rm -f "$log"; done; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && rm -rf "${WORKDIR}" || :

# Labels for run
LABEL \
 docker.run.options="-d -P -h httpd-onbuild --privileged" \
 docker.run.confirm-startup=""

