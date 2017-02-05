#
# centos7-systemd:nodered-onbuild
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:nodered-onbuild"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-systemd:nodered

# Maintainer
MAINTAINER MT

# Work dir
ONBUILD \
ARG \
 WORKDIR="/tmp/workdir"
ONBUILD \
WORKDIR \
 ${WORKDIR}

# Copy contents
ONBUILD \
COPY \
 node-red/* ${WORKDIR}/

# Init
ONBUILD \
RUN \
 set -x; . /etc/sysconfig/node-red; \
 _user="${NODERED_USER:-node-red}"; \
 _group="${NODERED_GROUP:-$_user}"; \
 _homedir="${NODERED_HOME:-/home/$_user}"; \
 tar --exclude "*.*.sam" -cv . |tar -C "${_homedir}/" -xf - && \
 [ -d "${_homedir}" ] && \
 (cd "${_homedir}" && { \
   chown -R "${_user}:${_group}" "." && \
   chmod 0775 "." && \
   [ -d "./node_modules" ] || { \
    mkdir -p "./node_modules"; } && \
   [ -d "./node_modules" ] && { \
    chown -R "${_user}:${_group}" "./node_modules" && \
    chmod 2775 "./node_modules"; }; \
 }) && \
 cd "${_homedir}" && { \
  [ ! -s "./package.json" ] || { \
   su - "${_user}" -c 'npm install'; } && \
  [ ! -e "./setup.sh" ] || { \
   bash ./setup.sh && rm -f ./setup.sh; }; \
 };

# Reset Work dir
ONBUILD \
WORKDIR /

# Cleanup
ONBUILD \
RUN \
 set -x; \
 for log in $(find /var/log -type f 2>/dev/null); \
 do [ -f "$log" ] && cat /dev/null 1>"$log"; done 2>/dev/null || :; \
 for log in {,/root,/tmp,/var/tmp}/*.log; \
 do rm -f "$log"; done 2>/dev/null || :; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
 rm -rf "${WORKDIR}"; } || :

# Labels for run
LABEL \
 docker.run.options="-d -P -h nodered-onbuild --privileged" \
 docker.run.confirm-startup=""

