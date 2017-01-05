#
# centos7-systemd:nodered
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:nodered"
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

# Install rpm packages
RUN \
 set -x; \
 yum -v -y update && \
 yum -v -y clean all

# Install node-red
RUN \
 set -x; \
 npm -g install node-red && \
 npm -g cache clean; \
 rm -rf /tmp/npm* || :; \

# Create a Symlink of node-red under the /usr/local/bin directory.
RUN \
 set -x; \
 . /etc/profile.d/nodebrew.sh && \
 [ -n "$(type -P node-red)" ] || exit 1; \
 [ -e "/usr/local/bin/node-red" ] || \
 ln -sf "$(type -P node-red)" /usr/local/bin/node-red;

# COPY sysconfig file to /etc/sysconfig
COPY \
 node-red.sysconfig /etc/sysconfig/node-red
ARG \
 NODERED_USER=node-red
ARG \
 NODERED_GROUP="${NODERED_USER:-node-red}"
ARG \
 NODERED_HOME="/home/${NODERED_USER:-node-red}"
ARG \
 NODERED_PORT=1880
ARG \
 NODERED_OPTIONS=
RUN \
 set -x; \
 _sysconfig=/etc/sysconfig/node-red; \
 chown root:root "$_sysconfig" && \
 chmod 0644 "$_sysconfig" && { \
  [ "${NODERED_HOME:-/home/node-red}" = "/home/node-red" ] || \
  sed -ri 's;^[ #]*(NODERED_HOME)=.*$;\1="'$NODERED_HOME'";g' "$_sysconfig"; \
  [ "${NODERED_USER:-node-red}" = "node-red" ] || \
  sed -ri 's;^[ #]*(NODERED_USER)=.*$;\1="'$NODERED_USER'";g' "$_sysconfig"; \
  [ "${NODERED_GROUP:-node-red}" = "node-red" ] || \
  sed -ri 's;^[ #]*(NODERED_GROUP)=.*$;\1="'$NODERED_GROUP'";g' "$_sysconfig"; \
  [ "${NODERED_PORT:-1880}" = "1880" ] || \
  sed -ri 's;^[ #]*(NODERED_PORT)=.*$;\1="'$NODERED_PORT'";g' "$_sysconfig"; \
  [ -z "${NODERED_OPTIONS}" ] || \
  sed -ri 's;^[ #]*(NODERED_OPTIONS)=.*$;\1="'$NODERED_OPTIONS'";g' "$_sysconfig"; \
 };

# Create node-red user
ARG \
 NODERED_UID=1880
ARG \
 NODERED_GID=1880
ARG \
 NODERED_PASSWD=node-red
RUN \
 set -x; . /etc/sysconfig/node-red; \
 _user="${NODERED_USER:-node-red}"; \
 _group="${NODERED_GROUP:-$_user}"; \
 _uid="${NODERED_UID:-1880}"; \
 _gid="${NODERED_GID:-1880}"; \
 _passwd="${NODERED_PASSWD:-$_user}"; \
 _homedir="${NODERED_HOME:-/home/$_user}"; \
 [ -z "$_group" ] || { \
  grep "^$_group" /etc/group 1>/dev/null 2>&1 || \
  groupadd ${_gid:+-g $_gid} "${_group}"; \
 } && \
 [ -n "$_user" ] && { \
  grep -E "^$_user" /etc/passwd 1>/dev/null 2>&1 || \
  useradd ${_uid:+-u $_uid} ${_group:+-g $_group} ${_homedir:+-d $_homedir} -m "${_user}" && \
  echo "${_user}:${_passwd}" |chpasswd; \
 } && \
 [ -d "${_homedir}/node_modules" ] || { \
  mkdir -p "${_homedir}/node_modules"; \
 } && \
 chown "${_user}:${_group}" "${_homedir}/node_modules" && \
 chmod 2775 "${_homedir}/node_modules";

# Register systemd
COPY \
 node-red.service /etc/systemd/system/
RUN \
 set -x; . /etc/sysconfig/node-red; \
 _servicefile=/etc/systemd/system/node-red.service; \
 chown root:root "$_servicefile" && \
 chmod 0644 "$_servicefile" && \
 systemctl enable node-red.service;

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
 . /etc/sysconfig/node-red && \
 curl -sL -o /dev/null "http://localhost:${NODERED_PORT:-1880}/"

# Publish a container's port(s) to the host
EXPOSE ${NODERED_PORT:-1880}

