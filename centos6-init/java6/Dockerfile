#
# centos6-init:java6
#
#@  DOCKER_TAG="centos6-init:java6"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h java6-machine"
#@  CONTAINER_NOT_START="yes"
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:ssh

# Install packages
RUN \
 set -x; \
 url_base="http://download.oracle.com/otn-pub/java/jdk" && \
 yum -y update && \
 cd /tmp && \
 curl -s -LO -b "oraclelicense=accept-securebackup-cookie" \
 "${url_base}/6u45-b06/jdk-6u45-linux-x64-rpm.bin" && \
 sh *.bin && \
 rm -f *.bin *.rpm

# Bind port
EXPOSE 22

# Start /sbin/init
CMD /sbin/init
