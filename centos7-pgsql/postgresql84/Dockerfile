#
# centos7-pgsql:postgresql84
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7-pgsql:postgresql84"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PGSQLVER=8.4.22"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PGTAPVER=0.99.0"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PG_GCC_PKG=compat-gcc-44"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PG_GCC_CMD=/usr/bin/gcc44"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-pgsql:pgsql

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="PostgreSQLP84 Server on CentOS7 with Systemd"

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos7pgsql84 --privileged" \
 docker.run.confirm-startup=". /etc/sysconfig/postgresql && su - $PGUSER -c 'psql -l'"

