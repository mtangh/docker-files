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
 NODEJS_SETUP=setup_7.x
ARG \
 NODEJS_URL=https://rpm.nodesource.com/${NODEJS_SETUP}
RUN \
 set -x; \
 curl -sL "${NODESOURCE_URL}" |bash - && \
 yum -y update && \
 yum -y install nodejs && \
 yum -y clean all && { \
   echo "$(type -P node): $(node --version)"; \
   echo "$(type -P npm): $(npm --version)"; \
 }

# Install nodejs packages
RUN \
 set -x; \
 npm -g install semver && \
 npm -g install n encoding-japanese && \
 npm -g up && \
 npm -g cache clean && \
 npm -g ls

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in {,/root,/tmp}/*.log; do rm -f "$log"; done; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && rm -rf "${WORKDIR}" || :

# Reset Work dir
WORKDIR /

