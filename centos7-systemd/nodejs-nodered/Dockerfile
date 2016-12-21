#
# centos7-systemd:nodejs-nodered
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:nodejs-nodered"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h nodered --privileged"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos7-systemd:nodejs

# Maintainer
MAINTAINER MT
 
# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 ${WORKDIR}

# Install node-red
RUN \
 set -x; \
 npm update -g && \
 npm install -g node-red && \
 npm cache clean && \
 npm info -g node-red

# Create node-red user
COPY \
 node-red.sysconfig /etc/sysconfig/node-red
RUN \
 set -x; . /etc/sysconfig/node-red; \
 nruser="${NODERED_USER:-node-red}"; \
 nrpasswd="${NODERED_PASSWD:-$nruser}"; \
 nrgroup="${NODERED_GROUP:-$nruser}"; \
 nr_uid="${NODERED_UID:-1880}"; \
 nr_gid="${NODERED_GID:-1880}"; \
 homedir="${NODERED_HOME:-/home/$nruser}"; \
 groupadd -g "${nr_gid}" "${nrgroup}" && \
 useradd -u "${nr_uid}" -g "${nrgroup}" -d "${homedir}" -m "${nruser}" && \
 echo "${nruser}:${nrpasswd}" |chpasswd

# Register systemd
COPY \
 node-red.service /etc/systemd/system/
RUN \
 set-x; \
 systemctl enable node-red.service

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in {,/root,/tmp}/*.log; do rm -f "$log"; done; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && rm -rf "${WORKDIR}" || :

# Reset Work dir
WORKDIR /

# Publish a container's port(s) to the host
EXPOSE 1880

