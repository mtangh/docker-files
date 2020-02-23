#
# centos7-pgsql:postgresql100
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7-pgsql:postgresql100"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PGSQLVER=10.6"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PGTAPVER=0.99.0"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-pgsql:pgsql

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="PostgreSQL100 Server on CentOS7 with Systemd"

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos7pgsql100 --privileged" \
 docker.run.confirm-startup=". /etc/sysconfig/postgresql && su - $PGUSER -c 'psql -l'"

