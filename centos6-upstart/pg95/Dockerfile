#
# centos6-upstart:pg95
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-upstart:pg95"
#@  DOCKER_BUILDOPTS="--build-arg PGSQLVER=9.5.5 --build-arg PGTAPVER=0.97.0"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos6-upstart:pg9x-onbuild

# Maintainer
MAINTAINER MT

# Labels for run
LABEL \
 docker.run.options="-d -P -h pg95-server" \
 docker.run.confirm-startup="su - postgres -c 'psql -l'"

# PGPORT
ARG PGPORT="5432"

# Publish a container's port(s) to the host
EXPOSE ${PGPORT}

