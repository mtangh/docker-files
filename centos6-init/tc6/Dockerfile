#
# centos6-init:tc6
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:tc6"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h tomcat6-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:java6

# Install packages for Tomcat6
RUN \
 yum check && \
 yum -y update && \
 yum -y install tar && \
 yum clean -y all

# Create 'tomcat' user and group
RUN \
 tcuser=tomcat; && \
 tc_uid=92; && \
 groupadd -g ${tc_uid:-26} ${tcuser} && \
 useradd -u ${tc_uid:-26} -g ${tcuser} -m ${tcuser} && \
 echo "${tcuser}:${tcuser}" |chpasswd

# Install tomcat to the /opt
RUN \
 tc_url=""; \
 wget

# Make DIR
RUN mkdir -p /tmp/conf

# Tomcat 6 config and init script
COPY conf/*.* /tmp/conf/

# Bind port
EXPOSE 22 80 443 8080 8443

# Start /sbin/init
CMD /sbin/init
