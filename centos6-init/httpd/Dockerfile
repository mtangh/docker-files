#
# centos6-init:httpd
#
#@  DOCKER_TAG="centos6-init:httpd"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h httpd-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:ssh

# Install packages for Apache (and PHP)
RUN \
 yum check && \
 yum -y update && \
 yum -y install httpd mod-ssl php && \
 yum clean -y all

# Bind port
EXPOSE 22 80 443 8080 8443

# Start /sbin/init
CMD /sbin/init
