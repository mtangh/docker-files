#
# centos7-systemd:nodejs
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:nodejs"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h nodejs-server --privileged"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos7-systemd:ssh

# Maintainer
MAINTAINER MT

# Install packages
RUN \
 set -x; \
 yum -y update && \
 yum -y install nodejs npm  && \
 yum -y clean all

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in /tmp/*.log; do rm -f "$log"; done

