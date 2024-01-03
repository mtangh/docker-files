#
# centos7-systemd-tomcat:0
#
#@  DOCKER_IMAGEPATH="centos7-systemd-tomcat:0"
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

# Extra RPM Packages
ARG ONBUILD_RPM_PACKAGES=""

# OnBuild Script
ARG ONBUILD_SHELL_SCRIPT="tc_base_setup.sh"

# Java package list
ARG TC_JAVA_PKG_LIST="tomcat-java-packages.txt"

# Tomcat sysconfig parameters
ARG JAVA_HOME="" \
    TOMCAT_HOME="" \
    TOMCAT_USER="" \
    TOMCAT_GROUP="" \
    CATALINA_HOME="" \
    CATALINA_BASE=""

# Download and install tomcat
ARG TC_PKGBASE="http://ftp.jaist.ac.jp/pub/apache/tomcat/" \
    TC_PKG_URL=""

# Tomcat instances
ARG TC_INSTANCES="tomcat"

# Image from
FROM centos7-systemd-onbuild

# Reset Work dir
WORKDIR /

# Labels
LABEL \
 name="Template of Tomcat Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.build.template="true" \
 org.ugoole.options.docker.build=""

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: Copy contents
ONBUILD \
COPY * ./

# ONBUILD: Java package list
ONBUILD \
ARG TC_JAVA_PKG_LIST

# ONBUILD: Tomcat sysconfig parameters
ONBUILD \
ARG JAVA_HOME \
    TOMCAT_HOME \
    TOMCAT_USER \
    TOMCAT_GROUP \
    CATALINA_HOME \
    CATALINA_BASE

# ONBUILD: Download and install tomcat
ONBUILD \
ARG TC_PKGBASE \
    TC_PKG_URL

# ONBUILD: Tomcat instances
ONBUILD \
ARG TC_INSTANCES

# ONBUILD: Update ayaconfig, download and install tomcat,
ONBUILD \
RUN \
 set -ux; work_dir=$(pwd); \
 [ -n "${TC_PKG_URL:-}" ] || { \
  echo "'TC_PKG_URL' is not set !!" 1>&2; \
  exit 1; }; \
 : "ONBUILD: Export vars" && { \
  export TC_JAVA_PKG_LIST; \
  export TC_PKG_URL TC_PKGBASE;\
  export JAVA_HOME; \
  export TOMCAT_HOME TOMCAT_USER TOMCAT_GROUP; \
  export CATALINA_HOME CATALINA_BASE; \
  export TC_INSTANCES; \
 } && \
 : "ONBUILD: Install tomcat (From:%{TC_PKG_URL})" && { \
  [ ! -s "${work_dir}/onbuild.sh" ] || { \
   mv -fv {${work_dir},/.onbuild}"/onbuild.sh"; } && \
  [ ! -d "${work_dir}/onbuild" ] || { \
   mv -fv "${work_dir}/onbuild"/*.sh /.onbuild/ 2>/dev/null; } && \
  bash -ux -o errtrace -o functrace -o pipefail \
  /.onbuild/onbuild.sh && rm -rf /.onbuild; \
 } && \
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y remove $(echo $( \
   package-cleanup --leaves )) || :; \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup" && { \
  cd / && [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; \
  done || :; rm -f /var/lib/rpm/__db.* || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# Reset Work dir
ONBUILD \
WORKDIR /

