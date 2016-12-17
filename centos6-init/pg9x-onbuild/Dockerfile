#
# centos6-init:pg9x-onbuild
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:pg9x-onbuild"
#@  DOCKER_BUILDER_OPTS=""
#@  DOCKER_STARTUP_OPTS="-h pg9x-onbuild"
#@  CONTAINER_NOT_START="yes"
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:pg9x

# Maintainer
MAINTAINER MT

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

# PGDATA
ONBUILD \
ARG \
 PGPDATA=""

# PGPORT
ONBUILD \
ARG \
 PGPORT="5432"

# Update sysconfig
ONBUILD \
RUN \
 set -x; \
 pgsysconf="/etc/sysconfig/postgresql"; \
 [ -n "$PGDATA" ] && { \
  grep -E '^[ ]*PGDATA='${PGDATA}'[ ]*$' "$pgsysconf" 1>/dev/null 2>&1 || { \
   echo "Update PGDATA = '$PGDATA'."; \
   sed -i 's/^[ ]*PGDATA=[^ ]*[ ]*$/PGDATA='${PGDATA}'/g' "$pgsysconf"; \
 }; }; \
 [ -n "$PGPORT" ] && { \
  grep -E '^[ ]*PGPORT='${PGPORT}'[ ]*$' "$pgsysconf" 1>/dev/null 2>&1 || { \
   echo "Update PGPORT = '$PGPORT'."; \
   sed -i 's/^[ ]*PGPORT=[^ ]*[ ]*$/PGPORT='${PGPORT}'/g' "$pgsysconf"; \
 }; }; \
 echo "$pgsysconf" && \
 cat "$pgsysconf"

# Install postgresql
ONBUILD \
ARG \
 PG_CONFIGURE_OPTIONS=""
ONBUILD \
RUN \
 [ -n "$PGSQLVER" ] || { \
  echo "'PGSQLVER' is not set !!" 1>&2; \
  exit 127; \
 }; \
 set -x; . /etc/sysconfig/postgresql && \
 pgname="postgresql-${PGSQLVER}" && \
 pg_ver="${PGSQLVER}" && \
 pg_url="https://ftp.postgresql.org/pub/source/v${pg_ver}/${pgname}.tar.gz" && \
 curl -s -o - "${pg_url}" |tar -zpxvf - && \
 ( cd "${pgname}" && \
   ./configure --prefix="${PGHOME}-${pg_ver}" ${PG_CONFIGURE_OPTIONS} && \
   make && make install && \
   cd ./contrib && make && make install; ) && \
 ( cd "${PGHOME}" && { \
    rm -rf "${PGHOME}-latest"; \
    ln -sf "${PGHOME}-${pg_ver}" "${PGHOME}-latest"; \
   } && \
   for dir in "${PGHOME}/archivelogs" "${PGDATA}"; do \
    [ -d "$dir" ] || mkdir -p "$dir"; \
    chown "${PGUSER}:${PGUSER}" "$dir" && \
    chmod 2750 "$dir"; \
   done && \
   for dir in bin include lib share; do \
    [ -e "$dir" ] && rm -rf "./$dir"; \
    ln -sf "${PGHOME}-latest/$dir" .; \
   done; )

# Install pgTAP
ONBUILD \
RUN \
 if [ -n "${PGTAPVER}" ]; \
 then \
  set -x; . /etc/sysconfig/postgresql && \
  pgtapname="pgtap-${PGTAPVER}" && \
  pgtap_ver="${PGTAPVER}" && \
  pgtap_url="http://api.pgxn.org/dist/pgtap/${pgtap_ver}/${pgtapname}.zip" && \
  curl -s -o "${pgtapname}.zip" "${pgtap_url}" && unzip "${pgtapname}.zip" && \
  ( export PATH="$PATH:${PGHOME}/bin" && \
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
  export PERL_AUTOINSTALL='--defaultdeps' && \
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
 /sbin/chkconfig --add postgresql && \
 /sbin/chkconfig --levels 2345 postgresql on; \
 /sbin/chkconfig --list |grep postgresql

# Init database
ONBUILD \
ARG \
 PG_INITDB_OPTIONS="-E UTF-8 --locale=C"
ONBUILD \
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 [ -d "$dir" ] || mkdir -p "$dir"; \
 chown "${PGUSER}:${PGUSER}" "$dir" && \
 chmod 2750 "$dir"; \
 su "${PGUSER}" -c "LANG= ${PGHOME}/bin/initdb ${PG_INITDB_OPTIONS} ${PGDATA}"

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
 options="$options "$([ -n "$PGDATA" ] && echo "-D $PGDATA"); \
 options="$options "$([ -n "$PGPORT" ] && echo "-p $PGPORT"); \
 . /etc/sysconfig/postgresql && \
 bash ${PGHOME}/dbbuild.sh $options "${WORKDIR}/data"

# Cleanup
ONBUILD \
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in /tmp/*.log; do rm -f "$log"; done

# Reset Work dir
ONBUILD \
WORKDIR \
 /
ONBUILD \
RUN \
 rm -rf "${WORKDIR}"

