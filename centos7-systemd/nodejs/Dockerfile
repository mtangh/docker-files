#
# centos7-systemd:nodejs
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:nodejs"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h nodejs-server --privileged"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos7-systemd:ssh

# Maintainer
MAINTAINER MT

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 ${WORKDIR}

# Install packages
ARG \
 NODEJS_SETUP_SUFFIX=7.x
RUN \
 set -x; \
 curl -sL https://rpm.nodesource.com/setup_${NODEJS_SETUP_SUFFIX} |bash - && \
 yum -y update && \
 yum -y install nodejs && \
 yum -y clean all

# Install nodejs packages
RUN \
 set -x; \
 npm up -g && \
 npm install -g n encoding-japanese && \
 npm cache clean && \
 npm ls -g

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in {,/root,/tmp}/*.log; do rm -f "$log"; done; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && rm -rf "${WORKDIR}" || :

# Reset Work dir
WORKDIR /

