#
# centos6-init:httpd-onbuild
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:httpd-onbuild"
#@  DOCKER_BUILDER_OPTS=""
#@  DOCKER_STARTUP_OPTS="-h httpd-onbuild"
#@  CONTAINER_NOT_START="yes"
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:httpd

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
WORKDIR \
 /

