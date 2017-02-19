#
# centos7-pg9:postgresql95
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-pg9:postgresql95"
#@  DOCKER_BUILDOPTS="--build-arg PGSQLVER=9.5.5 --build-arg PGTAPVER=0.97.0"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-pg9:pg9

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="PostgreSQL95 Server on CentOS7 with Systemd"

# Labels for run
LABEL \
 docker.run.options="-d -P -h postgresql95 --privileged" \
 docker.run.confirm-startup="su - postgres -c 'psql -l'"

# PGPORT
ARG PGPORT="5432"

# Publish a container's port(s) to the host
EXPOSE ${PGPORT}

