#
# centos6-init:pg95
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:pg95"
#@  DOCKER_BUILDER_OPTS="--build-arg PGSQLVER=9.5.5 --build-arg PGTAPVER=0.97.0"
#@  DOCKER_STARTUP_OPTS="-h pg95-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD="su - postgres -c 'psql -l'"
#
FROM centos6-init:pg9x-onbuild

# Maintainer
MAINTAINER MT

# PGPORT
ARG PGPORT="5432"

# Publish a container's port(s) to the host
EXPOSE ${PGPORT}

