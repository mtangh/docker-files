#
# centos7-pgsql:postgresql82
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-pgsql:postgresql82"
#@  DOCKER_BUILDOPTS="--build-arg PGSQLVER=8.2.23 --build-arg PGTAPVER=0.99.0"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PG_GCC_PKG=compat-gcc-44"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PG_GCC_CMD=/usr/bin/gcc44"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-pgsql:pgsql

# Maintainer
MAINTAINER MT

# Install packages for PostgreSQL (and pgTAP)
RUN \
 set -x; \
 yum -y update && \
 yum -y install \
  which tar unzip gcc patch readline-devel zlib-devel \
  perl perl-CPAN perl-parent && \
 yum -y clean all

# Labels
LABEL \
 name="postgresql82 Server on CentOS7 with Systemd"

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos7pgsql82 --privileged" \
 docker.run.confirm-startup="su - postgres -c 'psql -l'"

# PGPORT
ARG PGPORT="5432"

# Publish a container's port(s) to the host
EXPOSE ${PGPORT}

