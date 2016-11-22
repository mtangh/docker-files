#
# centos6-init:tc6
#
#@ DOCKER_TAG="centos6-init:tc6"
#@ DOCKER_BUILDER_OPTS=
#@ DOCKER_STARTUP_OPTS="-h tc6-server"
#
FROM centos6-init:java6

# Install packages for PostgreSQL (and pgTAP)

# Bind port
EXPOSE 22 80 8080

# Start /sbin/init
CMD /sbin/init
