#
# centos7-pgsql:pgsql
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-pgsql:pgsql"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Template of PostgreSQL Server on CentOS7 with Systemd"

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 "${WORKDIR}"

# Install packages for PostgreSQL (and pgTAP)
RUN \
 set -x; \
 yum -y update && \
 yum -y install \
  which tar unzip gcc patch readline-devel zlib-devel && \
 yum -y clean all

# COPY sysconfig file to /etc/sysconfig
COPY \
 postgresql.sysconfig /etc/sysconfig/postgresql
RUN \
 set -x; \
 chown root:root /etc/sysconfig/postgresql && \
 chmod 0644 /etc/sysconfig/postgresql

# Create 'postgres' user and group
ARG \
 PG_UID=""
ARG \
 PGPASSWORD=""
RUN \
 set -x; \
 . /etc/sysconfig/postgresql && \
 groupadd -g "${PG_UID:-26}" "${PGUSER}" && \
 useradd -u "${PG_UID:-26}" -g "${PGUSER}" -d "${PGHOME}" -m "${PGUSER}" && \
 echo "${PGUSER}:${PGPASSWORD:-$PGUSER}" |chpasswd

# Setup $PGHOME
RUN \
 set -x; \
 . /etc/sysconfig/postgresql && \
 [ -d "${PGHOME}" ] || { \
  mkdir -p "${PGHOME}" && \
  chown "${PGUSER}:${PGUSER}" "${PGHOME}" && \
  chmod 0755 "${PGHOME}"; \
 }; \
 : && { \
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
 } >>"${PGHOME}/.bashrc"

# Install init and db build script
COPY \
 postgresql.* ${WORKDIR}/
RUN \
 set -x; \
 . /etc/sysconfig/postgresql && \
 mv -f "${WORKDIR}/postgresql.service" "/etc/systemd/system/" && \
 chown root:root /etc/systemd/system/postgresql.service && \
 chmod 0644 /etc/systemd/system/postgresql.service && \
 [ -d "/usr/local/bin" ] || { \
  mkdir -p "/usr/local/bin"; \
 } || : ; \
 for pg_shell_scr in pgsysconfig pginstall pgdbbuild; \
 do \
  [ -e "${WORKDIR}/postgresql.${pg_shell_scr}.sh" ] && { \
    mv -f \
      "${WORKDIR}/postgresql.${pg_shell_scr}.sh" \
      "/usr/local/bin/${pg_shell_scr}.sh" && \
    chown "root:root" "/usr/local/bin/${pg_shell_scr}.sh" && \
    chmod 0775 "/usr/local/bin/${pg_shell_scr}.sh" && \
    ln -sf "/usr/local/bin/${pg_shell_scr}.sh" "${PGHOME}"/; \
  }; \
 done

# Reset Work dir
WORKDIR /

# Cleanup
RUN \
 set -x; \
 for log in $(find /var/log -type f 2>/dev/null); \
 do [ -f "$log" ] && cat /dev/null 1>"$log"; done 2>/dev/null || :; \
 for log in {,/root,/tmp,/var/tmp}/*.log; \
 do rm -f "$log"; done 2>/dev/null || :; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
 rm -rf "${WORKDIR}"; } || :

#-
#- Begin ONBUILDs
#-

# Work dir
ONBUILD \
ARG \
 WORKDIR=/tmp/workdir
ONBUILD \
WORKDIR \
 "${WORKDIR}"

# PostgreSQL Version
ONBUILD \
ARG \
 PGSQLVER=""

# pgTap Version
ONBUILD \
ARG \
 PGTAPVER=""

# PGUSER
ONBUILD \
ARG \
 PGUSER="postgres"

# PGHOME
ONBUILD \
ARG \
 PGHOME="/opt/postgresql"

# PGROOT
ONBUILD \
ARG \
 PGROOT="/opt/postgresql"

# PGDATA
ONBUILD \
ARG \
 PGDATA="/opt/postgresql/data"

# PGPORT
ONBUILD \
ARG \
 PGPORT="5432"

# PGPASSWORD
ONBUILD \
ARG \
 PGPASSWORD=""

# PGARCHLOGDIR
ONBUILD \
ARG \
 PGARCHLOGDIR=""

# PostgreSQL sysconfig Updat
ONBUILD \
RUN \
 set -x; \
 bash -vx /usr/local/bin/pgsysconfig.sh \
  -f "/etc/sysconfig/postgresql" \
  "PGSQLVER=${PGSQLVER}" \
  "PGUSER=${PGUSER}" \
  "PGHOME=${PGHOME}" \
  "PGROOT=${PGROOT}" \
  "PGDATA=${PGDATA}" \
  "PGPORT=${PGPORT}"

# Install postgresql and pgTAP
ONBUILD \
ARG \
 PG_GCC_PKG=""
ONBUILD \
ARG \
 PG_GCC_CMD=""
ONBUILD \
ARG \
 PG_CONFIGURE_OPTS=""
ONBUILD \
RUN \
 [ -n "$PGSQLVER" ] || { \
  echo "'PGSQLVER' is not set !!" 1>&2; \
  exit 127; \
 }; \
 set -x; \
 . /etc/sysconfig/postgresql && \
 bash -vx /usr/local/bin/pginstall.sh \
  -w "${WORKDIR}" \
  "PGSQLVER=${PGSQLVER}" \
  "PGTAPVER=${PGTAPVER}" \
  "PG_GCC_PKG=${PG_GCC_PKG}" \
  "PG_GCC_CMD=${PG_GCC_CMD}" \
  "PG_CONFIGURE_OPTS=${PG_CONFIGURE_OPTS}" \
  "PGARCHLOGDIR=${PGARCHLOGDIR}"

# Add to the service
ONBUILD \
ARG \
 PGCTL_START_OPTS=""
ONBUILD \
ARG \
 PGCTL_STOP_OPTS=""
ONBUILD \
ARG \
 PGCTL_RELOAD_OPTS=""
ONBUILD \
RUN \
 set -x; \
 bash -vx /usr/local/bin/pgsysconfig.sh \
  -f "/etc/sysconfig/postgresql" \
  "PGCTL_START_OPTS=${PGCTL_START_OPTS}" \
  "PGCTL_STOP_OPTS="${PGCTL_STOP_OPTS}" \
  "PGCTL_RELOAD_OPTS="${PGCTL_RELOAD_OPTS}" && \
 systemctl enable postgresql.service || :

# Init database
ONBUILD \
ARG \
 PG_INITDB_OPTS="-E UTF-8 --locale=C"
ONBUILD \
RUN \
 set -x; \
 . /etc/sysconfig/postgresql && \
 [ -d "${PGDATA}" ] || mkdir -p "${PGDATA}"; \
 chown "${PGUSER}:${PGUSER}" "${PGDATA}" && \
 chmod 2750 "${PGDATA}"; \
 su - "${PGUSER}" -c "LANG= ${PGROOT}/bin/initdb ${PG_INITDB_OPTS} ${PGDATA}"

ONBUILD \
WORKDIR \
 "${WORKDIR}/data"

# Copy data
ONBUILD \
COPY \
 data/* ${WORKDIR}/data/

# Setup default config
ONBUILD \
RUN \
 set -x; \
 . /etc/sysconfig/postgresql && \
 for config in *.conf; do \
  [ -r "${PGDATA}/${config}" ] && \
  [ ! -e "${PGDATA}/${config}.ORIG" ] && \
   cp -pf "${PGDATA}/${config}"{,.ORIG}; \
  { mv -f "${config}" "${PGDATA}/${config}" && \
   chown "${PGUSER}:${PGUSER}" "${PGDATA}/${config}" && \
   chmod 0644 "${PGDATA}/${config}"; } || break; \
 done

# Database build
ONBUILD \
RUN \
 set -x; \
 . /etc/sysconfig/postgresql; \
 bash -vx /usr/local/bin/pgdbbuild.sh \
  -f "/etc/sysconfig/postgresql" \
  "${WORKDIR}/data"

# Reset Work dir
ONBUILD \
WORKDIR /

# Cleanup
ONBUILD \
RUN \
 set -x; \
 for log in $(find /var/log -type f 2>/dev/null); \
 do [ -f "$log" ] && cat /dev/null 1>"$log"; done 2>/dev/null || :; \
 for log in {,/root,/tmp,/var/tmp}/*.log; \
 do rm -f "$log"; done 2>/dev/null || :; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
 rm -rf "${WORKDIR}"; } || :

#-
#- End of ONBUILDs
#-

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos7pgsql-onbuild --privileged" \
 docker.run.confirm-startup=""

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 . /etc/sysconfig/postgresql; \
 [ ! -x "${PGROOT}/bin/psql" ] || su - "${PGUSER}" -c 'psql -l';
