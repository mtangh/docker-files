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
  which tar unzip gcc patch readline-devel zlib-devel \
  perl perl-CPAN perl-parent && \
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
 set -x; . /etc/sysconfig/postgresql && \
 groupadd -g "${PG_UID:-26}" "${PGUSER}" && \
 useradd -u "${PG_UID:-26}" -g "${PGUSER}" -d "${PGHOME}" -m "${PGUSER}" && \
 echo "${PGUSER}:${PGPASSWORD:-$PGUSER}" |chpasswd

# Setup $PGHOME
RUN \
 set -x; . /etc/sysconfig/postgresql && \
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
 set -x; . /etc/sysconfig/postgresql && \
 mv -f "${WORKDIR}/postgresql.service" "/etc/systemd/system/" && \
 chown root:root /etc/systemd/system/postgresql.service && \
 chmod 0644 /etc/systemd/system/postgresql.service && \
 mv -f "${WORKDIR}/postgresql.dbbuild.sh" "${PGHOME}/dbbuild.sh" && \
 chown "root:${PGUSER}" "${PGHOME}/dbbuild.sh" && \
 chmod 0775 "${PGHOME}/dbbuild.sh"

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

# PGALOG
ONBUILD \
ARG \
 PGALOG="/opt/postgresql/archivelogs"

# PGPORT
ONBUILD \
ARG \
 PGPORT="5432"

# Update sysconfig
ONBUILD \
RUN \
 set -x; \
 pgsysconf="/etc/sysconfig/postgresql"; \
 [ -n "$PGUSER" ] && { \
  grep -E '^[ ]*PGUSER='${PGUSER}'[ ]*$' "$pgsysconf" 1>/dev/null 2>&1 || { \
   PGUSER_OLD=$(sed -nre 's/^[ ]*PGUSER=([^ ]+)[ ]*$/\1/gp' "$pgsysconf"); \
   echo "Update PGUSER = '$PGUSER'."; \
   sed -i 's/^[ ]*PGUSER=[^ ]+[ ]*$/PGUSER='${PGUSER}'/g' "$pgsysconf"; \
   [ -z "${PGUSER_OLD}" ] || { \
    usermod -l "${PGUSER}" "${PGUSER_OLD}"; \
    groupmod -n "${PGUSER}" "${PGUSER_OLD}"; \
   }; \
 }; }; \
 [ -n "$PGHOME" ] && { \
  grep -E '^[ ]*PGHOME='${PGHOME}'[ ]*$' "$pgsysconf" 1>/dev/null 2>&1 || { \
   echo "Update PGHOME = '$PGHOME'."; \
   sed -i 's/^[ ]*PGHOME=[^ ]+[ ]*$/PGHOME='${PGHOME}'/g' "$pgsysconf"; \
   usermod -d "${PGHOME}" -m "${PGUSER}"; \
 }; }; \
 [ -n "$PGROOT" ] && { \
  grep -E '^[ ]*PGROOT='${PGROOT}'[ ]*$' "$pgsysconf" 1>/dev/null 2>&1 || { \
   echo "Update PGROOT = '$PGROOT'."; \
   sed -i 's/^[ ]*PGROOT=[^ ]+[ ]*$/PGROOT='${PGROOT}'/g' "$pgsysconf"; \
 }; }; \
 [ -n "$PGDATA" ] && { \
  grep -E '^[ ]*PGDATA='${PGDATA}'[ ]*$' "$pgsysconf" 1>/dev/null 2>&1 || { \
   echo "Update PGDATA = '$PGDATA'."; \
   sed -i 's/^[ ]*PGDATA=[^ ]+[ ]*$/PGDATA='${PGDATA}'/g' "$pgsysconf"; \
 }; }; \
 [ -n "$PGPORT" ] && { \
  grep -E '^[ ]*PGPORT='${PGPORT}'[ ]*$' "$pgsysconf" 1>/dev/null 2>&1 || { \
   echo "Update PGPORT = '$PGPORT'."; \
   sed -i 's/^[ ]*PGPORT=[^ ]+[ ]*$/PGPORT='${PGPORT}'/g' "$pgsysconf"; \
 }; }; \
 case "${PGSQLVAR}" in \
 8.[0-2]*) \
  sed -i 's/^[ ]*(PGCTL_START_OPTS)=[^ ].*[^ ]*[ ]*$/\1="-s -w"/g' "$pgsysconf" ;; \
 *) \
  sed -i 's/^[ ]*(PGCTL_START_OPTS)=[^ ].*[^ ]*[ ]*$/\1="-s -w -t 300"/g' "$pgsysconf" ;; \
 esac; \
 echo "$pgsysconf" && \
 cat "$pgsysconf"

# Install postgresql
ONBUILD \
ARG \
 PG_GCC_PKG=""
ONBUILD \
ARG \
 PG_GCC_CMD=""
ONBUILD \
ARG \
 PG_CONFIGURE_OPTIONS=""
ONBUILD \
RUN \
 [ -n "$PGSQLVER" ] || { \
  echo "'PGSQLVER' is not set !!" 1>&2; \
  exit 127; \
 }; \
 set -x; \
 [ -n "${PG_GCC_PKG}" ] && { \
  yum -y update && yum -y install "${PG_GCC_PKG}" &&  yum -y clean all; \
 }; \
 . /etc/sysconfig/postgresql && \
 pgname="postgresql-${PGSQLVER}" && \
 pg_ver="${PGSQLVER}" && \
 pg_url="https://ftp.postgresql.org/pub/source/v${pg_ver}/${pgname}.tar.gz" && \
 curl -sL -o - "${pg_url}" |tar -zpxvf - && \
 ( [ -n "${PG_GCC_CMD}" -a -x "${PG_GCC_CMD}" ] && { \
    CC="${PG_GCC_CMD}"; export CC; \
   }; \
   cd "${pgname}" && \
   ./configure --prefix="${PGROOT}-${pg_ver}" ${PG_CONFIGURE_OPTIONS} && \
   make && make install && \
   cd ./contrib && make && make install; ) && \
 ( [ -d "${PGROOT}" ] || { \
    mkdir -p "${PGROOT}"; \
   }; \
   cd "${PGROOT}" && { \
    rm -rf "${PGROOT}-latest"; \
    ln -sf "${PGROOT}-${pg_ver}" "${PGROOT}-latest"; \
   } && \
   for dir in bin include lib share; do \
    [ -e "${dir}" ] && rm -rf "${dir}"; \
    ln -sf "${PGROOT}-latest/${dir}" .; \
   done; ); \
 ( cd "${PGHOME}" && { \
    PGALOG="${PGALOG:-archivelogs}"; \
    for dir in "${PGDATA}" "${PGALOG}"; do \
     [ -d "${dir}" ] || mkdir -p "${dir}"; \
     chown "${PGUSER}:${PGUSER}" "${dir}" && \
     chmod 2750 "${dir}"; \
    done; \
   }; );

# Install pgTAP
ONBUILD \
RUN \
 if [ -n "${PGTAPVER}" ]; \
 then \
  set -x; . /etc/sysconfig/postgresql && \
  pgtapname="pgtap-${PGTAPVER}" && \
  pgtap_ver="${PGTAPVER}" && \
  pgtap_url="http://api.pgxn.org/dist/pgtap/${pgtap_ver}/${pgtapname}.zip" && \
  curl -sL -o "${pgtapname}.zip" "${pgtap_url}" && unzip "${pgtapname}.zip" && \
  ( export PATH="$PATH:${PGROOT}/bin" && \
    cd "${pgtapname}" && \
    make && make install; ) && \
  rm -rf "./${pgtapname}"*; \
 else \
  echo "'PGTAPVER' is not set, skipping."; \
 fi

# Install pg_prove
ONBUILD \
RUN \
 if [ -n "${PGTAPVER}" ]; \
 then \
  set -x; \
  export PERL_MM_OPT="install_base" && \
  export PERL_AUTOINSTALL="--defaultdeps" && \
  cpan -i Module::Build && \
  cpan -i TAP::Parser::SourceHandler::pgTAP && \
  rm -rf /root/.cpan; \
 else \
  echo "'PGTAPVER' is not set, skipping."; \
 fi

# Add to the service
ONBUILD \
RUN \
 set -x; \
 systemctl enable postgresql.service || :

# Init database
ONBUILD \
ARG \
 PG_INITDB_OPTIONS="-E UTF-8 --locale=C"
ONBUILD \
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 [ -d "${PGDATA}" ] || mkdir -p "${PGDATA}"; \
 chown "${PGUSER}:${PGUSER}" "${PGDATA}" && \
 chmod 2750 "${PGDATA}"; \
 su - "${PGUSER}" -c "LANG= ${PGROOT}/bin/initdb ${PG_INITDB_OPTIONS} ${PGDATA}"

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
 set -x; . /etc/sysconfig/postgresql && \
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
 options=""; \
 options="${options:+$options }${PGDATA:+-D $PGDATA}"; \
 options="${options:+$options }${PGPORT:+-p $PGPORT}"; \
 . /etc/sysconfig/postgresql && \
 bash ${PGHOME}/dbbuild.sh $options "${WORKDIR}/data"

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
