#
# centos6-init:java-onbuild
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:java-onbuild"
#@  DOCKER_BUILDER_OPTS=""
#@  DOCKER_STARTUP_OPTS="-h java-onbuild"
#@  CONTAINER_NOT_START="yes"
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:ssh

# Maintainer
MAINTAINER MT

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
 yum -y update && \
 curl ${curlopts} -b "${o_cookie}" "${url_base}${jdk_path}" && \
 case "${jdk_file_name}" in \
 *.bin) sh *.bin ;; \
 *.rpm) rpm -Uvh jdk*.rpm ;; \
 *) ;; \
 esac && \
 yum -y clean all

# Cleanup
ONBUILD \
RUN \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in /tmp/*.log; do rm -f "$log"; done

# Work dir reset
ONBUILD \
WORKDIR \
 /
ONBUILD \
RUN \
 rm -rf "${WORKDIR}"

