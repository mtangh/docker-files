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
 cd /tmp && \
 url_base="http://download.oracle.com/otn-pub/java/jdk" && \
 curlopts='-s -LO -b "oraclelicense=accept-securebackup-cookie"' && \
 curl $curlopts "${url_base}/6u45-b15/jdk-6u45-linux-x64.rpm" && \
 rpm -Uvh *.rpm && \
 rm -f *.rpm

# Bind port
EXPOSE 22

# Start /sbin/init
CMD /sbin/init
