#
# almalinux8-nodejs:18
#
#@  DOCKER_IMAGEPATH="almalinux8-nodejs:18"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS=""
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}"
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}-${DOCKER_IMAGE_VER}"
#

# Node.Js Major version
ARG NODEJS_MAJOR_VER="18"

# Image from
FROM almalinux8-nodejs:0

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Node.js v${NODEJS_MAJOR_VER} on AlmaLinux8 Minimal" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h almalinux8-nodejs-v${NODEJS_MAJOR_VER} --privileged" \
 org.ugoole.docker.run.confirm-startup=""

# ONBUILD: Change Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: COPY files
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; work_dir=$(pwd); \
 [ -e "./onbuild.sh" ] || exit 0; \
 : "ONBUILD: Run" && { \
  /bin/bash -ux -o errtrace -o functrace -o pipefail \
  "./onbuild.sh" || exit 1; \
 } && \
 : "ONBUILD: DNF Cleanup." && { \
  dnf -v -y remove $(echo $( \
   dnf -q repoquery --unneeded 2>/dev/null  )) || :;\
  dnf -v -y clean all || :; \
  [ -d "/var/cache/dnf/" ] && \
  rm -rf /var/cache/dnf/* || :; \
 } && \
 : "ONBUILD: Cleanup" && { \
  cd / && [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; \
  done || :; rm -f /var/lib/rpm/__db.* || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /
