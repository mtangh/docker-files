#
# centos7s-postgresql:110
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7s-postgresql:110"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PGSQLVER=11.10"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS} --build-arg PGTAPVER=0.99.0"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#

# PostgreSQL Container Image Version
ARG PGSQL_IMAGE_VER=110


# PostgreSQL Server
FROM centos7s-postgresql:0

# PostgreSQL Container Image Version
ARG PGSQL_IMAGE_VER

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="PostgreSQL${PGSQL_IMAGE_VER} Server on CentOS7 with Systemd (build-stage)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 build-stage="true"


# PostgreSQL Server
FROM scratch

# PostgreSQL Container Image Version
ARG PGSQL_IMAGE_VER

# COPY From build-stage
COPY --from=0 / /

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="PostgreSQL${PGSQL_IMAGE_VER} Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-postgresql_${PGSQL_IMAGE_VER} --privileged" \
 docker.run.confirm-startup=". /etc/sysconfig/postgresql && su - ${PGUSER} -c 'psql -l'"

# STOP SIGNAL
STOPSIGNAL SIGINT

# Volume
VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init", "3" ]

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 . /etc/sysconfig/postgresql; \
 [ ! -x "${PGROOT}/bin/psql" ] || su - "${PGUSER}" -c 'psql -l';

