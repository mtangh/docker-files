#
# centos7s-postgresql:0
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7s-postgresql:0"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#
FROM centos7s-with-ssh:latest

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY sysconfig file to /etc/sysconfig
COPY postgresql.sysconfig /etc/sysconfig/postgresql

# COPY systemd files
COPY postgresql.service /etc/systemd/system/

# COPY scripts to workdir
COPY postgresql.*.sh ./

# PGUSER UID
ARG PG_UID="26"

# PGUSER USER
ARG PGUSER="postgres"

# PGUSER PASSWORD
ARG PGPASSWORD=""

# SetUp
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "SetUp sysconfig" && { \
  chown root:root /etc/sysconfig/postgresql && \
  chmod 0644 /etc/sysconfig/postgresql; \
 } || exit 97; \
 : "Load sysconfig" && { \
  . /etc/sysconfig/postgresql; \
  [ -n "${PGUSER}" -a -n "${PGROOT}" -a -n "${PGHOME}" ]; \
 } || exit 99; \
 : "Create 'postgres' user and group" && { \
  groupadd -g "${PG_UID:-26}" "${PGUSER}" && \
  useradd -u "${PG_UID:-26}" -g "${PGUSER}" -d "${PGHOME}" -m "${PGUSER}" && \
  echo "${PGUSER}:${PGPASSWORD:-$PGUSER}" |chpasswd; \
 } && \
 : "SetUp $PGHOME" && { \
  [ -d "${PGHOME}" ] || { \
   mkdir -p "${PGHOME}" && \
   chown "${PGUSER}:${PGUSER}" "${PGHOME}" && \
   chmod 0755 "${PGHOME}"; \
  } && \
  : "SetUp postgres's .bashrc" && { \
   echo '' && \
   echo '# For PostgreSQL' && \
   echo 'if [ -r "/etc/sysconfig/postgresql" ]' && \
   echo 'then' && \
   echo '  . /etc/sysconfig/postgresql' && \
   echo '  export PGUSER PGHOME PGROOT PGDATA PGPORT' && \
   echo 'fi' && \
   echo 'if [ -z "$(type -P psql)" -a -x "${PGROOT:-X}/bin/psql" ]' && \
   echo 'then' && \
   echo '  PATH="${PGROOT}/bin:${PATH}"' && \
   echo '  export PATH' && \
   echo 'fi' && \
   echo ''; \
  } 1>>"${PGHOME}/.bashrc"; \
 } && \
 : "Install systemd service file, and db* scripts" && { \
  [ -s "/etc/systemd/system/postgresql.service" ] && { \
   chown root:root /etc/systemd/system/postgresql.service && \
   chmod 0644 /etc/systemd/system/postgresql.service; \
  } && \
  [ -d "/usr/local/bin" ] || { \
   mkdir -p "/usr/local/bin" && \
   chown root:root /usr/local/bin && \
   chmod 0755 /usr/local/bin; \
  } && \
  for pg_shell_scr in pgsysconfig pginstall pgdbbuild; \
  do \
   [ -e "${work_dir}/postgresql.${pg_shell_scr}.sh" ] && { \
    mv -f \
      "${work_dir}/postgresql.${pg_shell_scr}.sh" \
      "/usr/local/bin/${pg_shell_scr}.sh" && \
    chown "root:root" "/usr/local/bin/${pg_shell_scr}.sh" && \
    chmod 0775 "/usr/local/bin/${pg_shell_scr}.sh" && \
    ln -sf "/usr/local/bin/${pg_shell_scr}.sh" "${PGHOME}"/; \
   }; \
  done; \
 } && \
 : "YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "Done.";

# Reset Work dir
WORKDIR /

# Labels
LABEL \
 name="Template of PostgreSQL Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="" \
 docker.run.confirm-startup=""

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 . /etc/sysconfig/postgresql; \
 [ ! -x "${PGROOT}/bin/psql" ] || su - "${PGUSER}" -c 'psql -l';


# ONBUILD: Set workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: PostgreSQL and pgTap Version
ONBUILD \
ARG PGSQLVER=""
ONBUILD \
ARG PGTAPVER=""

# ONBUILD: PostgreSQL sysconfig
ONBUILD \
ARG PGUSER="postgres"
ONBUILD \
ARG PGHOME="/opt/postgresql"
ONBUILD \
ARG PGROOT="/opt/postgresql"
ONBUILD \
ARG PGDATA="/opt/postgresql/data"
ONBUILD \
ARG PGPORT="5432"

# ONBUILD: PGPASSWORD
ONBUILD \
ARG PGPASSWORD=""

# ONBUILD: PGARCHLOGDIR
ONBUILD \
ARG PGARCHLOGDIR=""

# ONBUILD: pg_ctl command options
ONBUILD \
ARG PGCTL_START_OPTS=""
ONBUILD \
ARG PGCTL_STOP_OPTS=""
ONBUILD \
ARG PGCTL_RELOAD_OPTS=""

# ONBUILD: Compiler and configure opts
ONBUILD \
ARG PG_GCC_PKG=""
ONBUILD \
ARG PG_GCC_CMD=""
ONBUILD \
ARG PG_CONFIGURE_OPTS=""

# ONBUILD: initdb command options
ONBUILD \
ARG PG_INITDB_OPTS="-E UTF-8 --locale=C"

# ONBUILD: Install postgresql and pgTAP, pg_prove
ONBUILD \
RUN \
 [ -n "$PGSQLVER" ] || { \
  echo "'PGSQLVER' is not set !!" 1>&2; \
  exit 127; \
 }; \
 set -x; \
 : "ONBUILD: Update sysconfig" && { \
  bash -vx /usr/local/bin/pgsysconfig.sh \
   -f "/etc/sysconfig/postgresql" \
   "PGSQLVER=${PGSQLVER}" \
   "PGUSER=${PGUSER}" \
   "PGHOME=${PGHOME}" \
   "PGROOT=${PGROOT}" \
   "PGDATA=${PGDATA}" \
   "PGPORT=${PGPORT}" \
   "PGCTL_START_OPTS=${PGCTL_START_OPTS}" \
   "PGCTL_STOP_OPTS=${PGCTL_STOP_OPTS}" \
   "PGCTL_RELOAD_OPTS=${PGCTL_RELOAD_OPTS}" \
   || exit 98; \
 } && \
 : "ONBUILD: Load sysconfig" && { \
  . /etc/sysconfig/postgresql; \
  [ -n "${PGUSER}" -a -n "${PGROOT}" -a -n "${PGHOME}" ]; \
 } || exit 99; \
 : "ONBUILD: Install packages for PostgreSQL (and pgTAP)" && { \
  yum -y update && \
  yum -y install \
    which tar unzip make patch gcc readline-devel zlib-devel && \
  { rm -rf /var/cache/yum/* && yum -v -y clean all; }; \
 } && \
 : "ONBUILD: Install postgresql and pgTAP, pg_prove" && { \
  bash -vx /usr/local/bin/pginstall.sh \
   -w "${WORKDIR}" \
   "PGSQLVER=${PGSQLVER}" \
   "PGTAPVER=${PGTAPVER}" \
   "PG_GCC_PKG=${PG_GCC_PKG}" \
   "PG_GCC_CMD=${PG_GCC_CMD}" \
   "PG_CONFIGURE_OPTS=${PG_CONFIGURE_OPTS}" \
   "PGARCHLOGDIR=${PGARCHLOGDIR}" \
   || exit 100; \
 } && \
 : "ONBUILD: Init database" && { \
  [ -d "${PGDATA}" ] || mkdir -p "${PGDATA}"; \
  chown "${PGUSER}:${PGUSER}" "${PGDATA}" && \
  chmod 2750 "${PGDATA}"; \
  su - "${PGUSER}" -c "LANG= ${PGROOT}/bin/initdb ${PG_INITDB_OPTS} ${PGDATA}"; \
 } && \
 : "ONBUILD: Add to the service" && { \
  systemctl enable postgresql.service || :; \
 } && \
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Set workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build/data

# ONBUILD: COPY data
ONBUILD \
COPY data/* ./

# ONBUILD: Build database
ONBUILD \
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "ONBUILD: Load sysconfig" && { \
  . /etc/sysconfig/postgresql; \
  [ -n "${PGUSER}" -a -n "${PGROOT}" -a -n "${PGHOME}" ]; \
 } || exit 99; \
 : "ONBUILD: Setup default config" && { \
  for config in *.conf; do \
   [ -r "${PGDATA}/${config}" ] && \
   [ ! -e "${PGDATA}/${config}.ORIG" ] && \
    cp -pf "${PGDATA}/${config}"{,.ORIG}; \
   { mv -f "${config}" "${PGDATA}/${config}" && \
    chown "${PGUSER}:${PGUSER}" "${PGDATA}/${config}" && \
    chmod 0644 "${PGDATA}/${config}"; } || break; \
  done; \
 } && \
 : "ONBUILD: Database build" && { \
  bash -vx /usr/local/bin/pgdbbuild.sh \
   -f "/etc/sysconfig/postgresql" "${work_dir}" \
   || exit 102; \
 } && \
 : "YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

