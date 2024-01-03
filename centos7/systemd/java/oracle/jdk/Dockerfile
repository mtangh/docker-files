#
# centos7-java-oracle-jdk:0
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7-java-oracle-jdk:0"
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
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="" \
 org.ugoole.docker.run.confirm-startup=""

## JAVA JDK Version, etc...
#ONBUILD \
#ARG JAVA_JDK_VER=""
#ONBUILD \
#ARG JAVA_JDK_PKG_ARCH_TYPE="x64"
#ONBUILD \
#ARG JAVA_JDK_PKG_EXTENSION="rpm"

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# Copy contents
ONBUILD \
COPY jdk-*-linux-*.* ./

# SetUp
ONBUILD \
RUN \
 set -ux; \
 : "Lookup Package" && { \
  jdk_install_file=$( \
   ls -1r ./jdk-*-linux-*.* 2>/dev/null | \
   head -n 1); \
  if [ -n "${jdk_install_file}" ]; \
  then jdk_path="${jdk_install_file}"; \
  else \
   : "WEB Install" || { \
   [ -n "${JAVA_JDK_VER:-}" ] || { \
    echo "No build args: 'JAVA_JDK_VER'." 1>&2 && \
    exit 1; }; \
   url_base="http://download.oracle.com/otn-pub/java/jdk" && \
   jdk_path="/${JAVA_JDK_VER}/jdk-${JAVA_JDK_VER%-*}-linux-${JAVA_JDK_PKG_ARCH_TYPE:-x64}" && \
   case "${JAVA_JDK_PKG_EXTENSION:-rpm}" in \
   bin) jdk_path="${jdk_path}-rpm.bin" ;; \
   rpm) jdk_path="${jdk_path}.${JAVA_JDK_PKG_EXTENSION}" ;; \
   *) echo "Illegal file type: '${JAVA_JDK_PKG_EXTENSION}'." 1>&2 && \
      exit 1 ;; \
   esac && \
   o_cookie="oraclelicense=accept-securebackup-cookie" && \
   curl -sL -O -b "${o_cookie}" "${url_base}${jdk_path}"; \
   }; \
   echo "No sush file or directory." 1>&2 && \
   exit 1;
  fi; \
 } && \
 : "ONBUILD: Install Pakcage" && { \
  [ -n "${jdk_path:-}" -a -r "./${jdk_path##*/}" ] || { \
   echo "Package not found: 'jdk_path'." 1>&2 && \
   exit 2; }; \
  yum -v -y update && \
  case "${jdk_path}" in \
  *.bin) sh *.bin ;; \
  *.rpm) rpm -Uvh jdk*.rpm ;; \
  *) echo "Illegal archive type: '$jdk_path'." 1>&2 && \
     exit 1 ;; \
  esac && \
  yum -v -y clean all && { \
  rm -rf /var/cache/yum/* || :; }; \
 } && \
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


