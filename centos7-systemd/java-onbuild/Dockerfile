#
# centos7-systemd:java-onbuild
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:java-onbuild"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Java on CentOS7 with Systemd"

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
 jdk_version=""
ONBUILD \
ARG \
 jdk_arch="x64"
ONBUILD \
ARG \
 jdk_file_type="rpm"

# Install JDK
ONBUILD \
RUN \
 set -x; \
 [ -z "$jdk_version" ] && { \
  echo "No build args: 'jdk_version'."; \
 } 1>&2; \
 url_base="http://download.oracle.com/otn-pub/java/jdk" && \
 jdk_path="/${jdk_version}/jdk-${jdk_version%-*}-linux-${jdk_arch:-x64}" && \
 case "$jdk_file_type" in \
 bin) jdk_path="${jdk_path}-rpm.bin" ;; \
 *) jdk_path="${jdk_path}.${jdk_file_type}" ;; \
 esac && \
 curlopts="-s -LO" && \
 o_cookie="oraclelicense=accept-securebackup-cookie" && \
 yum -v -y update && \
 curl ${curlopts} -b "${o_cookie}" "${url_base}${jdk_path}" && \
 case "${jdk_path}" in \
 *.bin) sh *.bin ;; \
 *.rpm) rpm -Uvh jdk*.rpm ;; \
 *) ;; \
 esac && \
 yum -v -y clean all

# Work dir reset
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
 docker.run.options="-d -P -h java-onbuild --privileged" \
 docker.run.confirm-startup=""

