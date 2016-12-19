#
# centos7-systemd:nodejs-nodered
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:nodejs-nodered"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h nodered --privileged"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos7-systemd:nodejs

# Maintainer
MAINTAINER MT

# Install node-red
RUN \
 set -x; \
 npm install -g node-red && \
 npm cache clean

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in /tmp/*.log; do rm -f "$log"; done

# Publish a container's port(s) to the host
EXPOSE 1880

