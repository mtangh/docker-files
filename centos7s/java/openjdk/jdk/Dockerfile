#
# centos7s-java-openjdk
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7s-java-openjdk"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7s-with-ssh:latest AS 0

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
WORKDIR /tmp/docker-container-build

# ONBUILD: Copy contents to Workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -x; \
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
  yum -v -y remove $(echo $(package-cleanup --leaves)) && \
  yum -v -y clean all && { \
  rm -rf /var/cache/yum/* || :; }; \
 } &&\
 : "ONBUILD: Cleanup" && { \
  work_dir=$(pwd); cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf "${work_dir}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

