#
# centos6-upstart:httpd-onbuild
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-upstart:httpd-onbuild"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos6-upstart:httpd

# Maintainer
MAINTAINER MT

# Work dir
ONBUILD \
ARG \
 WORKDIR="/var/www"
ONBUILD \
WORKDIR \
 ${WORKDIR}

# Copy contents
ONBUILD \
COPY \
 www/ ${WORKDIR}/

# Init
ONBUILD \
RUN \
 set -x; \
 for item in etc/{,sysconfig/}httpd etc/php.{ini,d}; \
 do \
  [ -e "./${item}" ] || { \
    continue; \
  }; \
  if [ -f "./${item}" ]; \
  then cp -f "./${item}" "/${item}"; \
  elif [ -d "./${item}" ]; \
  then cp -rf "./${item}/"* "/${item}/"; \
  else :; \
  fi; \
 done; \
 [ ! -e "./setup.sh" ] || { \
  bash ./setup.sh && rm -f ./setup.sh; \ 
 } && \
 /usr/sbin/httpd -t && \
 [ ! -d "./etc/" ] || { rm -rf "./etc" || :; }

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
 docker.run.options="-d -P -h httpd-onbuild" \
 docker.run.confirm-startup=""

