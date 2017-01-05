#
# centos7-systemd:nodered-onbuild
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:nodered-onbuild"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-systemd:nodered-onbuild

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
 for item in $(ls -1 2>/dev/null); \
 do \
  if [ -e "./${item}" ]; \
  then \
    cp -rf "./${item}" "${NODERED_HOME}/" && \
    chown -R "${NODERED_USER}:${NODERED_GROUP} "${NODERED_HOME}/${item}"; \
  else \
    :; \
  fi; \
 done && \
 [ ! -s "$NODERED_HOME/project.js" ] || { \
  su - "$NODERED_USER" -c 'npm '; \
 } && \
 [ ! -e "./setup.sh" ] || { \
  bash ./setup.sh && rm -f ./setup.sh; \ 
 };

# Reset Work dir
ONBUILD \
WORKDIR /

# Cleanup
ONBUILD \
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in {,/root,/tmp}/*.log; do rm -f "$log"; done; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && rm -rf "${WORKDIR}" || :

# Labels for run
LABEL \
 docker.run.options="-d -P -h nodered-onbuild --privileged" \
 docker.run.confirm-startup=""

