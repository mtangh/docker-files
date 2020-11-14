#
# centos7s-nodejs-nodered
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#

# Node-RED on CentOS7 with Systemd
FROM centos7s-nodejs:stable AS latest

# Sysconfig parameters
ARG NODEREDOWNER="node-red"
ARG NODEREDGROUP="${NODEREDOWNER:-node-red}"
ARG NODERED_HOME="/home/${NODEREDOWNER:-node-red}"
ARG NODERED_PORT=1880
ARG NODERED_OPTS=

# node-red uid and gid
ARG NODERED_UID=1880
ARG NODERED_GID=1880

# node-red user password
ARG NODERED_PASSWD="${NODEREDOWNER:-node-red}"

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY sysconfig file to /etc/sysconfig
COPY node-red.sysconfig /etc/sysconfig/node-red
# Register systemd file
COPY node-red.service /etc/systemd/system/

# SetUp
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "Install node-red" && { \
  npm -g install node-red && \
  npm -g cache clean --force; \
 } && \
 : "Create a Symlink of node-red under the /usr/local/bin dir." && { \
  [ -n "$(type -P node-red)" ] || exit 1; \
  [ -e "/usr/local/bin/node-red" ] || \
  ln -sf "$(type -P node-red)" /usr/local/bin/node-red; \
 } && \
 : "Update sysconfig" && { \
  if [ "${_sysconfig:=/etc/sysconfig/node-red}" ]; \
  then \
   chown root:root "${_sysconfig}" && \
   chmod 0644 "${_sysconfig}" && { \
    [ "${NODERED_HOME:-/home/node-red}" = "/home/node-red" ] || \
    sed -ri 's;^[[:space:]#]*(NODERED_HOME)=.*$;\1="'"${NODERED_HOME}"'";g' "${_sysconfig}"; \
    [ "${NODEREDOWNER:-node-red}" = "node-red" ] || \
    sed -ri 's;^[[:space:]#]*(NODEREDOWNER)=.*$;\1="'"${NODEREDOWNER}"'";g' "${_sysconfig}"; \
    [ "${NODEREDGROUP:-node-red}" = "node-red" ] || \
    sed -ri 's;^[[:space:]#]*(NODEREDGROUP)=.*$;\1="'"${NODEREDGROUP}"'";g' "${_sysconfig}"; \
    [ "${NODERED_PORT:-1880}" = "1880" ] || \
    sed -ri 's;^[[:space:]#]*(NODERED_PORT)=.*$;\1="'"${NODERED_PORT}"'";g' "${_sysconfig}"; \
    [ -z "${NODERED_OPTS}" ] || \
    sed -ri 's;^[[:space:]#]*(NODERED_OPTS)=.*$;\1="'"${NODERED_OPTS}"'";g' "${_sysconfig}"; \
   }; \
  fi; \
 } && \
 : "Load sysconfig" && { \
  . "${_sysconfig}"; \
 } && \
 : "node-red user and group" && { \
  _nr_usrname="${NODEREDOWNER:-node-red}"; \
  _nr_grpname="${NODEREDGROUP:-${_nr_usrname}}"; \
  _nr_homedir="${NODERED_HOME:-/home/${_nr_usrname}}"; \
  [ -n "${_nr_usrname}" -a -n "${_nr_grpname}" -a -n "${_nr_homedir}" ]; \
 } && \
 : "node-red user UID and GID" && { \
  _nr_usr_uid="${NODERED_UID:-1880}"; \
  _nr_usr_gid="${NODERED_GID:-1880}"; \
  _nrpassword="${NODERED_PASSWD:-${_nr_usrname}}"; \
  [ -n "${_nr_usr_uid}" -a -n "${_nr_usr_gid}" -a -n "${_nrpassword}" ]; \
 } && \
 : "Create node-red user and group" && { \
  [ -z "${_nr_grpname}" ] || { \
   egrep "^${_nr_grpname}:" /etc/group 1>/dev/null 2>&1 || \
   groupadd -g "${_nr_usr_gid}" "${_nr_grpname}"; \
  } && \
  [ -n "${_nr_usrname}" ] && { \
   egrep "^${_nr_usrname}:" /etc/passwd 1>/dev/null 2>&1 || \
   useradd -u "${_nr_usr_uid}" -g "${_nr_grpname}" -d "${_nr_homedir}" -m "${_nr_usrname}" && \
   echo "${_nr_usrname}:${_nrpassword}" |chpasswd; \
  } && \
  [ -d "${_nr_homedir}/node_modules" ] || { \
   mkdir -p "${_nr_homedir}/node_modules"; \
  } && \
  chown "${_nr_usrname}:${_nr_grpname}" "${_nr_homedir}/node_modules" && \
  chmod 2775 "${_nr_homedir}/node_modules"; \
 } && \
 : "SetUp systemd file" && { \
  if [ "${_servicefile:=/etc/systemd/system/node-red.service}" ]; \
  then \
   chown root:root "${_servicefile}" && \
   chmod 0644 "${_servicefile}" && \
   systemctl enable node-red.service || :; \
  fi; \
 } && \
 : "YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "Done.";

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Node-RED on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-nodejs-nodered --privileged" \
 docker.run.confirm-startup=""

# Health check
HEALTHCHECK \
--interval=30s --timeout=15s --retries=3 \
CMD \
 . /etc/sysconfig/node-red && \
 curl -sL -o /dev/null "http://localhost:${NODERED_PORT:-1880}/"


# Node-RED on CentOS7 with Systemd (onbuild)
FROM latest AS latest-onbuild

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Node-RED on CentOS7 with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-nodejs-nodered --privileged" \
 docker.run.confirm-startup=""

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: Copy contents
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "ONBUILD: Load sysconfig" && { \
  if [ "${_sysconfig:=/etc/sysconfig/node-red}" ]; \
  then . "${_sysconfig}"; \
  fi; \
 } && \
 : "ONBUILD: node-red user and group" && { \
  _nr_usr_uid="${NODERED_UID:-1880}"; \
  _nr_usr_gid="${NODERED_GID:-1880}"; \
  _nrpassword="${NODERED_PASSWD:-${_nr_usrname}}"; \
  [ -n "${_nr_usr_uid}" -a -n "${_nr_usr_gid}" -a -n "${_nrpassword}" ]; \
 } && \
 : "ONBUILD: Initialize ${_nr_homedir}" && { \
  [ -d "${_nr_homedir}" ] || exit 1: \
  [ -d "./node-red" ] && { \
   (cd "./node-red" && { \
     tar --exclude "*.*.sam" -cv . | \
     tar -C "${_nr_homedir}/" -xf - ; \
   }); \
  } || exit 1; \
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
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Work dir
ONBUILD \
WORKDIR /

