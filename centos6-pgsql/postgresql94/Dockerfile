#
# centos6-pgsql:postgresql94
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos6-pgsql:postgresql94"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PGSQLVER=9.4.20"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PGTAPVER=0.99.0"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos6-pgsql:pgsql

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="PostgreSQL94 Server on CentOS6 with Upstart"

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos6pgsql94" \
 docker.run.confirm-startup=". /etc/sysconfig/postgresql && su - $PGUSER -c 'psql -l'"

