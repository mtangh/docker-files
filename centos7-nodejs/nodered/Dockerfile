#
# centos7-nodejs:nodered
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-nodejs:nodered"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-nodejs:nodejs

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="Node-RED on CentOS7 with Systemd"

# Work dir
ARG \
 WORKDIR=/tmp/workdir

# Set Workdir
WORKDIR \
 ${WORKDIR}

# Sysconfig parameters
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

# node-red uid and gid
ARG \
 NODERED_UID=1880
ARG \
 NODERED_GID=1880

# node-red user password
ARG \
 NODERED_PASSWD="${NODERED_USER:-node-red}"

# COPY sysconfig file to /etc/sysconfig
COPY \
 node-red.sysconfig /etc/sysconfig/node-red
# Register systemd
COPY \
 node-red.service /etc/systemd/system/

# Install node-red
RUN \
 set -x; \
 : "Install node-red" && { \
  npm -g install node-red && \
  npm -g cache clean; \
  rm -rf /tmp/npm* || :; \
 } && \
 : "Create a Symlink of node-red under the /usr/local/bin dir." && { \
  . /etc/profile.d/nodebrew.sh || exit 90; \
  [ -n "$(type -P node-red)" ] || exit 91; \
  [ -e "/usr/local/bin/node-red" ] || \
  ln -sf "$(type -P node-red)" /usr/local/bin/node-red; \
 }; \
 : "Update sysconfig" && { \
  _sysconfig="/etc/sysconfig/node-red"; \
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
  }; \
 }; \
 : "Load sysconfig" && { \
  . /etc/sysconfig/node-red; \
 } || exit 100; \
 : "node-red user and group" && { \
  _nr_usrname="${NODERED_USER:-node-red}"; \
  _nr_grpname="${NODERED_GROUP:-$_nr_usrname}"; \
  _nr_homedir="${NODERED_HOME:-/home/$_nr_usrname}"; \
  [ -n "$_nr_usrname" -a -n "$_nr_grpname" -a -n "$_nr_homedir" ]; \
 } || exit 101; \
 : "node-red user UID and GID" && { \
  _nr_usr_uid="${NODERED_UID:-1880}"; \
  _nr_usr_gid="${NODERED_GID:-1880}"; \
  _nrpassword="${NODERED_PASSWD:-$_nr_usrname}"; \
  [ -n "$_nr_usr_uid" -a -n "$_nr_usr_gid" -a -n "$_nrpassword" ]; \
 } || exit 102; \
 : "Create node-red user and group" && { \
  [ -z "$_nr_grpname" ] || { \
   egrep "^$_nr_grpname:" /etc/group 1>/dev/null 2>&1 || \
   groupadd -g "${_nr_usr_gid}" "${_nr_grpname}"; \
  } && \
  [ -n "$_nr_usrname" ] && { \
   egrep "^$_nr_usrname:" /etc/passwd 1>/dev/null 2>&1 || \
   useradd -u "${_nr_usr_uid}" -g "${_nr_grpname}" -d "${_nr_homedir}" -m "${_nr_usrname}" && \
   echo "${_nr_usrname}:${_nrpassword}" |chpasswd; \
  } && \
  [ -d "${_nr_homedir}/node_modules" ] || { \
   mkdir -p "${_nr_homedir}/node_modules"; \
  } && \
  chown "${_nr_usrname}:${_nr_grpname}" "${_nr_homedir}/node_modules" && \
  chmod 2775 "${_homedir}/node_modules"; \
 } || exit 103; \
 : "SetUp systemd file" && { \
  _servicefile="/etc/systemd/system/node-red.service"; \
  chown root:root "$_servicefile" && \
  chmod 0644 "$_servicefile" && \
  systemctl enable node-red.service || :; \
 }; \
 : "Cleanup" && {
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done || :; \
  [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
   cd /; rm -rf "${WORKDIR}"; } || :; \
 } 2>/dev/null; \
 echo;

# Reset Work dir
WORKDIR /

#-
#- Begin ONBUILDs
#-

# ONBUILD: Work dir
ONBUILD \
ARG \
 WORKDIR="/tmp/workdir"

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR \
 ${WORKDIR}

# ONBUILD: Copy contents
ONBUILD \
COPY \
 node-red/* ${WORKDIR}/

# ONBUILD: Init Node-red home dir
ONBUILD \
RUN \
 set -x; \
 : "ONBUILD: Load sysconfig" && { \
  . /etc/sysconfig/node-red; \
 } || exit 100; \
 : "ONBUILD: node-red user and group" && { \
  _nr_usrname="${NODERED_USER:-node-red}"; \
  _nr_grpname="${NODERED_GROUP:-$_nr_usrname}"; \
  _nr_homedir="${NODERED_HOME:-/home/$_nr_usrname}"; \
  [ -n "$_nr_usrname" -a -n "$_nr_grpname" -a -n "$_nr_homedir" ]; \
 } || exit 101; \
 : "ONBUILD: Initialize ${_nr_homedir}" && { \
  [ -d "${_nr_homedir}" ] && { \
   tar --exclude "*.*.sam" -cv . |tar -C "${_nr_homedir}/" -xf -;
  } || exit 102; \
  (cd "${_nr_homedir}" && { \
   chown -R "${_nr_usrname}:${_nr_grpname}" "." && \
   chmod 0775 "." && \
   [ -d "./node_modules" ] || { \
    mkdir -p "./node_modules"; } && \
   [ -d "./node_modules" ] && { \
    chown -R "${_nr_usrname}:${_nr_grpname}" "./node_modules" && \
    chmod 2775 "./node_modules"; }; \
  }); \
 }; \
 : "ONBUILD: SetUp ${_nr_homedir}" && { \
  (cd "${_nr_homedir}" && { \
   [ ! -s "./package.json" ] || { \
    su - "${_nr_usrname}" -c 'npm install'; } && \
   [ ! -e "./setup.sh" ] || { \
    bash ./setup.sh && rm -f ./setup.sh; }; \
  }); \
 }; \
 : "ONBUILD: Cleanup" && {
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done || :; \
  [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
   cd /; rm -rf "${WORKDIR}"; } || :; \
 } 2>/dev/null; \
 echo;

# ONBUILD: Reset Work dir
ONBUILD \
WORKDIR /

#-
#- End of ONBUILDs
#-

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

