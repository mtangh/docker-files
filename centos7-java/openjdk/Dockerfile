#
# centos7-java:openjdk
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-java:openjdk"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="Java-OpenJDK on CentOS7 with Systemd"

# Work dir reset
WORKDIR /

# Work dir
ONBUILD \
ARG \
 WORKDIR=/tmp/workdir

# Set Workdir
ONBUILD \
WORKDIR \
 "${WORKDIR}"

# Copy contents
ONBUILD \
COPY \
 * "${WORKDIR}/"

# Install the OpenJDK package
ONBUILD \
ARG \
 OPENJDK_PKG_LIST="./packages.txt"
ONBUILD \
RUN \
 set -x; \
 [ -n "${OPENJDK_PKG_LIST}" -a -s "${OPENJDK_PKG_LIST}" ] || { \
  echo "The OpenJDK Package List is empty." 1>&2; \
  exit 99; }; \
 : "ONUILD: Install OpenJDK Packages" && { \
  yum -v -y update && \
  yum -v -y $(echo $(cat "${OPENJDK_PKG_LIST}")) && \
  yum -v -y clean all && \
  rm -rf /var/cache/yum/*; \
  rm -f "${OPENJDK_PKG_LIST}" || :; \
 }; \
 : "ONBUILD: Cleanup" && { \
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done || :; \
  [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
   cd /; rm -rf "${WORKDIR}"; } || :; \
 } 2>/dev/null || :; \
 echo;

# Work dir reset
ONBUILD \
WORKDIR /

# Labels for run
LABEL \
 docker.run.options="-d -P -h javavm-openjdk-onbuild --privileged" \
 docker.run.confirm-startup=""

