#
# centos7-systemd-postgresql:0
#
#@  DOCKER_IMAGEPATH="centos7-systemd-postgresql:0"
#@  DOCKER_IMAGE_VER=""
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS=""
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}"
#

# Logrotate
ARG LOGROTATION="YES"

# Enable SUDO
ARG ENABLE_SUDO="YES"

# SSH Login
ARG ENABLE_SSHD="YES"

# Extra RPM Packages
ARG ONBUILD_RPM_PACKAGES=""

# OnBuild Script
ARG ONBUILD_SHELL_SCRIPT="pg_base_setup.sh"

# PGUSER USER and UID
ARG PGUSER="postgres" \
    PG_UID="26"

# PostgreSQL and pgTap Version
ARG PGSQLVER="" \
    PGTAPVER=""

# PostgreSQL sysconfig
ARG PGUSER="postgres" \
    PGHOME="/opt/postgresql" \
    PGROOT="/opt/postgresql" \
    PGDATA="/opt/postgresql/data" \
    PGPORT="5432"

# PGARCHLOGDIR
ARG PGARCHLOGDIR=""

# pg_ctl command options
ARG PGCTL_START_OPTS="" \
    PGCTL_STOP_OPTS="" \
    PGCTL_RELOAD_OPTS=""

# Compiler and configure opts
ARG PG_GCC_PKG="" \
    PG_GCC_CMD="" \
    PG_CONFIGURE_OPTS=""

# initdb command options
ARG PG_INITDB_OPTS="-E UTF-8 --locale=C"

# Image from
FROM centos7:systemd-onbuild

# Reset Work dir
WORKDIR /

# Labels
LABEL \
 name="Template of PostgreSQL Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.build.template="true" \
 org.ugoole.options.docker.build=""

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 . /etc/sysconfig/postgresql && \
 [ -x "${PGROOT}/bin/psql" ] && \
 su - "${PGUSER}" -c "${PGROOT}/bin/psql -l";

# ONBUILD: PostgreSQL and pgTap Version
ONBUILD \
ARG PGSQLVER \
    PGTAPVER

# ONBUILD: PostgreSQL sysconfig
ONBUILD \
ARG PGUSER \
    PGHOME \
    PGROOT \
    PGDATA \
    PGPORT

# ONBUILD: PGARCHLOGDIR
ONBUILD \
ARG PGARCHLOGDIR

# ONBUILD: pg_ctl command options
ONBUILD \
ARG PGCTL_START_OPTS \
    PGCTL_STOP_OPTS \
    PGCTL_RELOAD_OPTS

# ONBUILD: Compiler and configure opts
ONBUILD \
ARG PG_GCC_PKG \
    PG_GCC_CMD \
    PG_CONFIGURE_OPTS

# ONBUILD: initdb command options
ONBUILD \
ARG PG_INITDB_OPTS

# ONBUILD: Set workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: COPY contents to workdir
ONBUILD \
COPY * ./

# ONBUILD: Install postgresql and pgTAP, pg_prove
ONBUILD \
RUN \
 set -ux; work_dir=$(pwd); \
 [ -n "${PGSQLVER:-}" ] || { \
  echo "'PGSQLVER' is not set !!" 1>&2; \
  exit 1; }; \
 : "ONBUILD: Export vars" && { \
  export PGSQLVER PGTAPVER; \
  export PGUSER PGHOME PGROOT PGDATA PGPORT; \
  export PGARCHLOGDIR; \
  export PGCTL_START_OPTS; \
  export PGCTL_STOP_OPTS; \
  export PGCTL_RELOAD_OPTS; \
  export PG_GCC_PKG PG_GCC_CMD PG_CONFIGURE_OPTS; \
  export PG_INITDB_OPTS; \
 } && \
 : "ONBUILD: Install PostgreSQL v${PSQLVER} (and pgTAP ${PGTAPVER})" && { \
  onbuilddir="/usr/local/postgresql/.onbuild"; && \
  [ ! -s "${work_dir}/onbuild.sh" ] || { \
   mv -fv {${work_dir},${onbuilddir}}"/onbuild.sh"; } && \
  [ ! -d "${work_dir}/onbuild" ] || { \
   mv -fv "${work_dir}"/onbuild/*.sh "${onbuilddir}"/ 2>/dev/null; } && \
  bash -ux -o errtrace -o functrace -o pipefail \
  "${onbuilddir}"/onbuild.sh && rm -rf "${onbuilddir}"; \
 } && \
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y remove $(echo $( \
   package-cleanup --leaves )) || :; \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup" && { \
  cd / && [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; \
  done || :; rm -f /var/lib/rpm/__db.* || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

