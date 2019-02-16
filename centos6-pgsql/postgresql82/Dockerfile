#
# centos6-pgsql:postgresql82
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-pgsql:postgresql82"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PGSQLVER=8.2.23"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PGTAPVER=0.99.0"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PG_GCC_PKG=compat-gcc-44"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PG_GCC_CMD=/usr/bin/gcc44"
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
 docker.run.confirm-startup=". /etc/sysconfig/postgresql && su - $PGUSER -c 'psql -l'"

