#
# almalinux8-nodejs
#
#@  DOCKER_IMAGEPATH="almalinux8-nodejs:0"
#@  DOCKER_IMAGE_VER=""
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS="${DOCKER_IMAGEPATH}"
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}"
#

# Node.Js Major version
ARG NODEJS_MAJOR_VER=""

# Node.Js Install script url
ARG NODEJS_SETUP_URL=""

# Image from
FROM almalinux8:minimal

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Base image for Node.js on AlmaLinux8" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="" \
 org.ugoole.docker.run.confirm-startup=""

# Node.Js Major version
ONBUILD \
ARG NODEJS_MAJOR_VER

# Node.Js Install script url
ONBUILD \
ARG NODEJS_SETUP_URL

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
 [ -n "${NODEJS_MAJOR_VER:-}" ] || { \
  echo "'NODEJS_MAJOR_VER' is not set." 1>&2; \
  exit 1; }; \
 [ -n "${NODEJS_SETUP_URL:-}" ] || { \
  NODEJS_SETUP_URL="https://rpm.nodesource.com/nsolid_setup_rpm.sh"; \
  echo "'NODEJS_SETUP_URL' is not set. Using '${NODEJS_SETUP_URL}'."; }; \
 : "ONBUILD: Install" && { \
  dnf -v -y update && \
  dnf -v -y install yum && \
  curl -sSL -o ./setup_rpm.sh "${NODEJS_SETUP_URL}" && \
  [ -e "./setup_rpm.sh" ] && \
  /bin/bash -x -o errtrace -o functrace -o pipefail \
  ./setup_rpm.sh "${NODEJS_MAJOR_VER}" && \
  dnf -v -y --nodocs --setopt=nodesource-nodejs.module_hotfixes=1 \
   install nodejs && \
  rpm -e yum; \
 } && \
 : "ONBUILD: Print node and npm version" && { \
  node -v && npm -v && { \
   [ -x "$(type -P npm-g)" ] || ln -sf "$(type -P npm)"{,-g}; \
  }; \
 } && \
 if [ -e "./onbuild.sh" ]; \
 then \
  : "ONBUILD: Run" && /bin/bash -ux \
   -o errtrace -o functrace -o pipefail \
   "./onbuild.sh" || exit 1; \
 else :; \
 fi && \
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
