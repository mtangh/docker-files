#
# centos6-init:pg96
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:pg96"
#@  DOCKER_BUILDER_OPTS="--build-arg PGSQLVER=9.6.1 --build-arg PGTAPVER=0.97.0"
#@  DOCKER_STARTUP_OPTS="-h pg96-server"
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

