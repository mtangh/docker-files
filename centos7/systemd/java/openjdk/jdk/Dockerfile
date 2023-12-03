#
# centos7-systemd-java:openjdk0
#
#@  DOCKER_IMAGEPATH="centos7-systemd-java-openjdk:0"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS=""
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}-${DOCKER_IMAGE_VER}"
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}"
#

FROM centos7-systemd_with-ssh

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Base Image for Java-OpenJDK on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="" \
 docker.run.confirm-startup=""

# Install the OpenJDK package
ONBUILD \
ARG OPENJDK_PKG_LIST=""
ONBUILD \
ARG OPENJDK_PKG_FILE="packages.txt"

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: Copy contents to Workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; \
 work_dir=$(pwd); \
 packages=""; \
 if [ -n "${OPENJDK_PKG_LIST:-}" ]; \
 then packages="${OPENJDK_PKG_LIST}"; \
 elif [ -f "${OPENJDK_PKG_FILE:-}" -a -s "${OPENJDK_PKG_FILE:-}" ]; \
 then packages=$(echo $(cat "${OPENJDK_PKG_FILE}")); \
 fi; \
 [ -n "${packages}" ] || { \
  echo "The OpenJDK Package List is empty." 1>&2; \
  exit 1; }; \
 : "ONUILD: Install OpenJDK Packages" && { \
  yum -v -y update && \
  yum -v -y install $(echo ${packages}) && \
  yum -v -y remove $(echo $(package-cleanup --leaves)); \
 } &&\
 : "ONUILD: YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONUILD: Cleanup." && { \
  cd /; 
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; \
  done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

