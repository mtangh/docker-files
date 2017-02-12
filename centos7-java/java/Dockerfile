#
# centos7-java:java
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-java:java"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Template of Java machine on CentOS7 with Systemd"

# Work dir
ONBUILD \
ARG \
 WORKDIR=/tmp/workdir
ONBUILD \
WORKDIR \
 "${WORKDIR}"

# JDK Version
ONBUILD \
ARG \
 JDK_VERSION=""
ONBUILD \
ARG \
 JDK_ARCH_TYPE="x64"
ONBUILD \
ARG \
 JDK_PACKAGE_TYPE="rpm"

# Copy contents
ONBUILD \
COPY \
 * "${WORKDIR}"

# Install JDK
ONBUILD \
RUN \
 set -x; \
 jdk_install_file=$( \
 ls -1r ./jdk-*-linux-*.* 2>/dev/null |head -n 1); \
 if [ -n "${jdk_install_file}" ]; \
 then \
  jdk_path="${jdk_install_file}"; \
 else \
  [ -n "$JDK_VERSION" ] || { \
  echo "No build args: 'JDK_VERSION'." 1>&2 && exit 1; }; \
  url_base="http://download.oracle.com/otn-pub/java/jdk" && \
  jdk_path="/${JDK_VERSION}/jdk-${JDK_VERSION%-*}-linux-${JDK_ARCH_TYPE:-x64}" && \
  case "$JDK_PACKAGE_TYPE" in \
  bin) jdk_path="${jdk_path}-rpm.bin" ;; \
  rpm) jdk_path="${jdk_path}.${JDK_PACKAGE_TYPE}" ;; \
  *) echo "Illegal file type: '$JDK_PACKAGE_TYPE'." 1>&2 && exit 2 ;; \
  esac && \
  curlopts="-s -LO" && \
  o_cookie="oraclelicense=accept-securebackup-cookie" && \
  curl ${curlopts} -b "${o_cookie}" "${url_base}${jdk_path}"; \
 fi; \
 [ -n "${jdk_path}" -a -r "./${jdk_path##*/}" ] || { \
 echo "Package not found: 'jdk_path'." 1>&2 && exit 2; }; \
 yum -v -y update && \
 case "${jdk_path}" in \
 *.bin) sh *.bin ;; \
 *.rpm) rpm -Uvh jdk*.rpm ;; \
 *) echo "Illegal archive type: '$jdk_path'." 1>&2; exit 3 ;; \
 esac && \
 yum -v -y clean all;

# Work dir reset
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
 docker.run.options="-d -P -h java-onbuild --privileged" \
 docker.run.confirm-startup=""

