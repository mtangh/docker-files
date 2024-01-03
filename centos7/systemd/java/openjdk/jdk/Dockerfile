#
# centos7-systemd-java:openjdk0
#
#@  DOCKER_IMAGEPATH="centos7-systemd-java-openjdk:0"
#@  DOCKER_IMAGE_VER=""
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS=""
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}"
#

# Logrotate
ARG LOGROTATION="YES"

# Enable SUDO
ARG ENABLE_SUDO="YES"

# SSH Login
ARG ENABLE_SSHD="YES"

# Install the OpenJDK packages
ARG OPENJDK_PACKAGES="java-openjdk_packages.txt"

# Image from
FROM centos7:systemd-onbuild

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Base Image for Java-OpenJDK on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.build.template="true"

# Install the OpenJDK packages
ONBUILD \
ARG OPENJDK_PACKAGES

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: Copy contents to Workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; work_dir=$(pwd); \
 packages=""; \
 if [ -s "${OPENJDK_PACKAGES:=packages.txt}" ]; \
 then packages=$(echo $(cat "${OPENJDK_PKG_FILE}")); \
 elif [ -n "${OPENJDK_PACKAGES:-}" ]; \
 then packages=$(echo ${OPENJDK_PACKAGES:-}); \
 fi; \
 [ -n "${packages}" ] || { \
  echo "The OpenJDK Package List is empty." 1>&2; \
  exit 1; }; \
 : "ONUILD: Install OpenJDK Packages" && { \
  yum -v -y update && \
  yum -v -y install ${packages}; \
 } &&\
 : "ONUILD: YUM Cleanup." && { \
  yum -v -y remove $(echo $( \
   package-cleanup --leaves )) || :; \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONUILD: Cleanup." && { \
  cd / && [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; \
  done || :; rm -f /var/lib/rpm/__db.* || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

