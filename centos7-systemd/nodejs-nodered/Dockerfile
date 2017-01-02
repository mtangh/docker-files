#
# centos7-systemd:nodejs-nodered
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:nodejs-nodered"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-systemd:nodejs

# Maintainer
MAINTAINER MT
 
# Labels
LABEL \
 name="Node-RED on CentOS7 with Systemd"

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 ${WORKDIR}

# Install node-red
RUN \
 set -x; \
 npm -g install node-red && \
 npm -g cache clean; \
 rm -rf /tmp/npm*

# Create node-red user
ARG \
 NODERED_USER=node-red
ARG \
 NODERED_GROUP=node-red
ARG \
 NODERED_PASSWD=node-red
ARG \
 NODERED_UID=1880
ARG \
 NODERED_HOME=/home/${NODERED_USER}
RUN \
 set -x; \
 _user="${NODERED_USER:-node-red}"; \
 _group="${NODERED_GROUP:-$nruser}"; \
 _passwd="${NODERED_PASSWD:-$nruser}"; \
 _uid="${NODERED_UID:-1880}"; \
 _homedir="${NODERED_HOME:-/home/$nruser}"; \
 [ -n "$_group" ] && { \
  grep "$_group" /etc/group 1>/dev/null 2>&1 || \
  groupadd "${_group}"; }; \
 useradd ${_uid:+-u $_uid} ${_group:+-g $_group} ${_homedir:+-d $_homedir} -m "${_user}" && \
 echo "${_user}:${_passwd}" |chpasswd

# Register systemd
ARG \
 NODERED_PORT=1880
COPY \
 node-red.service /etc/systemd/system/
RUN \
 set-x; \
 _sysconfig=/etc/sysconfig/node-red; \
 _servicefile=/etc/systemd/system/node-red.service; \
 : && { \
  echo "# sysconfig/node-red" && \
  echo "" && \
  echo "# Node-RED Server Options" && \
  echo "NODERED_OPTIONS='-u $NODERED_HOME -p ${NODERED_PORT:-1880}'" && \
  echo ""; \
 } 1>"$_sysconfig"; cat "$_sysconfig"; \
 [ -n "$NODERED_HOME" -a "$NODERED_HOME" != "/home/node-red" ] && \
 sed -ri 's:^(WorkingDirectory)=.*$:\1='$NODERED_HOME':g' "$_servicefile"; \
 [ -n "$NODERED_USER" -a "$NODERED_USER" != "node-red" ] && \
 sed -ri 's:^(User)=.*$:\1='$NODERED_USER':g' "$_servicefile"; \
 [ -n "$NODERED_GROUP" -a "$NODERED_GROUP" != "node-red" ] && \
 sed -ri 's:^(Group)=.*$:\1='$NODERED_GROUP':g' "$_servicefile"; \
 systemctl enable node-red.service && \
 [ -z "$NODERED_HOME" ] || \
 [ ! -d "$NODERED_HOME/node_modules" ] || { \
  mkdir -p "$NODERED_HOME/node_modules" && \
  chown \
    "${NODERED_USER:-node-red}:${NODERED_GROUP:-$NODERED_USER}" \
    "$NODERED_HOME/node_modules"; };

# Reset Work dir
WORKDIR /

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in {,/root,/tmp}/*.log; do rm -f "$log"; done; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && rm -rf "${WORKDIR}" || :

# Labels for run
LABEL \
 docker.run.options="-d -P -h nodered-server --privileged" \
 docker.run.confirm-startup=""

# Health check
HEALTHCHECK \
--interval=30s --timeout=15s --retries=3 \
CMD \
 curl -sL -o /dev/null "http://localhost:${NODERED_PORT:-1880}/"

# Publish a container's port(s) to the host
EXPOSE ${NODERED_PORT:-1880}

