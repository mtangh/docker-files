#
# centos7-systemd:pg96
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:pg96"
#@  DOCKER_BUILDOPTS="--build-arg PGSQLVER=9.6.1 --build-arg PGTAPVER=0.97.0"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-systemd:pg9x-onbuild

# Maintainer
MAINTAINER MT

# Labels for run
LABEL \
 docker.run.options="-d -P -h pg96-server --privileged" \
 docker.run.confirm-startup="su - postgres -c 'psql -l'"

# PGPORT
ARG PGPORT="5432"

# Publish a container's port(s) to the host
EXPOSE ${PGPORT}

