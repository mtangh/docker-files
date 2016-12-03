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
 
# Install packages
RUN \
 set -x; \
 url_base="http://download.oracle.com/otn-pub/java/jdk" && \
 yum -y update && \
 cd /tmp && \
 curl -s -LO -b "oraclelicense=accept-securebackup-cookie" \
 "${url_base}/7u80-b15/jdk-7u80-linux-x64.rpm" && \
 rpm -Uvh *.rpm && \
 rm -f *.rpm

# Bind port
EXPOSE 22

# Start /sbin/init
CMD /sbin/init
