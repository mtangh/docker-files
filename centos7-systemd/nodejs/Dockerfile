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
RUN \
 set -x; \
 yum -y update && \
 yum -y clean all

ARG \
 NVM_VER=v0.30.1
RUN \
 set -x; \
 curl -o- https://raw.githubusercontent.com/creationix/nvm/${NVM_VER}/install.sh |bash && \
 . ${HOME}/.bash_profile && \
 nvm install stable && \
 node -v && \
 npm -v

# Install nodejs packages
RUN \
 set -x; \
 npm update -g && \
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

