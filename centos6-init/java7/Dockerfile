#
# centos6-init:java7
#
#@  DOCKER_TAG="centos6-init:java7"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h java7-machine"
#@  CONTAINER_NOT_START="yes"
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:ssh

# Maintainer
MAINTAINER MT

# JDK Version
ARG jdk_version=7u80
ARG jdk_build_no=b15
ARG jdk_file_name="jdk-${jdk_version}-linux-x64.rpm"

# Work dir.
ARG \
 workdir=/tmp/workdir
WORKDIR \
 "${workdir}"

# Install JDK
RUN \
 set -x; \
 url_base="http://download.oracle.com/otn-pub/java/jdk" && \
 jdk_path="/${jdk_version}-${jdk_build_no}/${jdk_file_name}" && \
 curlopts="-s -LO" && \
 o_cookie="oraclelicense=accept-securebackup-cookie" && \
 yum -y update && \
 curl ${curlopts} -b "${o_cookie}" "${url_base}/${jdk_path}" && \
 case "${jdk_file_name}" in \
 *.bin)  sh *.bin ;; \
 *.rpm)  rpm -Uvh *.rpm ;; \
 *) ;; \
 esac && \
 rm -f ./*.*

# Cleanup workdir
WORKDIR \
 /root
RUN \
 rm -rf "${workdir}"

# Bind port
EXPOSE 22

# Start /sbin/init
CMD /sbin/init
