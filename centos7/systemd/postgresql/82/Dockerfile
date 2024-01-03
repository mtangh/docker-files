#
# centos7-systemd-postgresql:82
#
#@  DOCKER_IMAGEPATH="centos7-systemd-postgresql:82"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS=""
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}"
#

# PostgreSQL Container Image Version
ARG PGSQL_IMAGE_VER=82

# PostgreSQL and pgTap Version
#ARG PGSQLVER="8.2.23" \
#    PGTAPVER="1.1.0"
ARG PGSQLVER="8.2.23" \
    PGTAPVER=""

# Compiler and configure opts
ARG PG_GCC_PKG="compat-gcc-44" \
    PG_GCC_CMD="/usr/bin/gcc44" \
    PG_CONFIGURE_OPTS=""

# Image from
FROM centos7-systemd-postgresql:0

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
 org.ugoole.build.template="true" \
 org.ugoole.options.docker.build=""


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
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h centos7-systemd-postgresql${PGSQL_IMAGE_VER} --privileged"

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

