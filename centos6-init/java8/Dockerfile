#
# centos6-init:java8
#
#@  DOCKER_TAG="centos6-init:java8"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h java8-machine"
#@  CONTAINER_NOT_START="yes"
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:ssh

# Install packages
RUN \
 set -x; \
 url_base="http://download.oracle.com/otn-pub/java/jdk" && \
 cd /tmp && \
 curl -s -LO -b "oraclelicense=accept-securebackup-cookie" \
 "${url_base}/8u112-b15/jdk-8u112-linux-x64.rpm" && \
 rpm -Uvh *.rpm && \
 rm -f *.rpm

# Bind port
EXPOSE 22

# Start /sbin/init
CMD /sbin/init
