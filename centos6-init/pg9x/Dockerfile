#
# centos6-init:pg9x
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:pg9x"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h pg9x-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:ssh

# Maintainer
MAINTAINER MT

# ------------------------------
# ONBUILD
# ------------------------------

# Work dir.
ONBUILD \
ARG \
 WORKDIR=/tmp/workdir
ONBUILD \
WORKDIR \
 "${WORKDIR}"

# PostgreSQL Version
ONBUILD \
ARG \
 PGSQL_VERSION=""

# pgTap Version
ONBUILD \
ARG \
 PGTAP_VERSION=""

# Install postgresql
ONBUILD \
ARG \
 PG_CONFIGURE_OPTIONS=""
ONBUILD \
RUN \
 [ -n "$PGSQL_VERSION" ] || { \
  echo "'PGSQL_VERSION' is not set !!" 1>&2; \
  exit 127; \
 }; \
 set -x; . /etc/sysconfig/postgresql && \
 pgname="postgresql-${PGSQL_VERSION}" && \
 pg_ver="${PGSQL_VERSION}" && \
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
   for dir in bin include lib share; do \
    rm -rf "./$dir"; ln -sf "${PGHOME}-latest/$dir" .; \
   done; ) && \
 rm -rf "./${pgname}"*

# Install pgTAP
ONBUILD \
RUN \
 if [ -n "${PGTAP_VERSION}" ]; \
 then \
  set -x; . /etc/sysconfig/postgresql && \
  pgtapname="pgtap-${PGTAP_VERSION}" && \
  pgtap_ver="${PGTAP_VERSION}" && \
  pgtap_url="http://api.pgxn.org/dist/pgtap/${pgtap_ver}/${pgtapname}.zip" && \
  curl -s -o - "${pgtap_url}" |unzip - && \
  ( export PATH="$PATH:${PGHOME}/bin" && \
    cd "${pgtapname}" && \
    make && make install; ) && \
  rm -rf "./${pgtapname}"*; \
 else \
  echo "'PGTAP_VERSION' is not set, skipping."; \
 fi

# Install pg_prove
ONBUILD \
RUN \
 if [ -n "${PGTAP_VERSION}" ]; \
 then \
  set -x; \
  export PERL_AUTOINSTALL='--defaultdeps' && \
  cpan -i Module::Build && \
  cpan -i TAP::Parser::SourceHandler::pgTAP && \
  rm -rf /root/.cpan; \
 else \
  echo "'PGTAP_VERSION' is not set, skipping."; \
 fi 

# Init database
ONBUILD \
ARG \
 PG_INITDB_OPTIONS="-E UTF-8 --locale=C"
ONBUILD \
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 su "${PGUSER}" -c "LANG= ${PGHOME}/bin/initdb ${PG_INITDB_OPTIONS} ${PGDATA}"

# Setup default config
ONBUILD\
COPY \
 *.conf ${WORKDIR}/
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

# Add to the service
ONBUILD \
RUN \
 set -x; \
 /sbin/chkconfig --add postgresql && \
 /sbin/chkconfig --levels 2345 postgresql on; \
 /sbin/chkconfig --list |grep postgresql

# Cleanup workdir
ONBUILD \
WORKDIR \
 /
ONBUILD \
RUN \
 rm -rf "${WORKDIR}"

# ------------------------------
# SETUP ENVIRONMENTS
# ------------------------------

# Install packages for PostgreSQL (and pgTAP)
RUN \
 set -x; \
 yum -y update && \
 yum -y install tar gcc readline-devel zlib-devel && \
 yum -y install which patch unzip && \
 yum -y install perl perl-CPAN perl-parent && \
 yum -y clean all

# COPY sysconfig file to /etc/sysconfig
COPY \
 pg.rc /etc/sysconfig/postgresql
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
 useradd -u "${PG_UID:-26}" -g "${PGUSER}" -m "${PGUSER}" && \
 echo "${PGUSER}:${PGPASSWORD:-$PGUSER}" |chpasswd

# Setup postgres/.bashrc
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 [ -d "/home/${PGUSER}" ] || { \
  mkdir -p "/home/${PGUSER}" && \
  chown "${PGUSER}:${PGUSER}" "/home/${PGUSER}" && \
  chmod 0755 "/home/${PGUSER}"; \
 }; \
 : && { \
  echo && \
  echo '# For PostgreSQL' && \
  echo '[ -r "/etc/sysconfig/postgresql" ] && {' && \
  echo '  . /etc/sysconfig/postgresql' && \
  echo '  export PGHOME PGDATA PGPORT' && \
  echo '}' \
  echo '[ -n "${PGHOME}" ] &&' && \
  echo '[ -d "${PGHOME}/bin" ] &&' && \
  echo '[ -z "$(type -p psql)" ] &&' && \
  echo 'export PATH="${PATH}:${PGHOME}/bin"' && \
  echo; \
 } >>"/home/${PGUSER}/.bashrc"

# Setup $PGHOME
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 mkdir -p ${PGHOME} && cd "${PGHOME}" && \
 chown -R "${PGUSER}:${PGUSER}" . && chmod -R 2755 . && \
 for dir in "${PGHOME}/archivelogs" "${PGDATA}"; do \
  { mkdir -p $dir && \
    chown "${PGUSER}:${PGUSER}" $dir && \
    chmod 0700 $dir; } || break; \
 done

# Install init and db build script
COPY \
 pg-init.sh /etc/init.d/postgresql
COPY \
 pg-dbbuild.sh /root/dbbuild.sh
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 mv -f  /root/dbbuild.sh "${PGHOME}/dbbuild.sh" && \
 chown root:root /etc/init.d/postgresql && \
 chmod 0755 /etc/init.d/postgresql && \
 chown "root:${PGUSER}" "${PGHOME}/dbbuild.sh" && \
 chmod 0775 "${PGHOME}/dbbuild.sh"

