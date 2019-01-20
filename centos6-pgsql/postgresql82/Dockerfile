#
# centos6-pgsql:postgresql82
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-pgsql:postgresql82"
#@  DOCKER_BUILDOPTS="--build-arg PGSQLVER=8.2.23 --build-arg PGTAPVER=0.99.0"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos6-pgsql:pgsql

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="PostgreSQL82 Server on CentOS6 with Upstart"

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos6pgsql82" \
 docker.run.confirm-startup="su - postgres -c 'psql -l'"

# PGPORT
ARG PGPORT="5432"

# Publish a container's port(s) to the host
EXPOSE ${PGPORT}

