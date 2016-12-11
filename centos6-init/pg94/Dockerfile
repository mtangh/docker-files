#
# centos6-init:pg94
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:pg94"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h pg94-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD="ps -ef|grep 'postgres: '"
#
FROM centos6-init:ssh

# Maintainer
MAINTAINER MT

# OnBuild Trigger
ONBUILD \
 ARG PGPORT=5432
ONBUILD \
 ARG workdir=/tmp/workdir
ONBUILD \
 WORKDIR ${workdir}/db
ONBUILD \
 COPY db/* ${workdir}/db/
ONBUILD \
 RUN \
  set -x; \
  bash /root/pg-dbbuild.sh -p "${PGPORT}" ${workdir}/db && \
  rm -rf "${workdir}/db"
ONBUILD \
 WORKDIR /root
ONBUILD \
 RUN \
  rm -rf "${workdir}"

# Install packages for PostgreSQL (and pgTAP)
RUN \
 set -x; \
 yum -y update && \
 yum -y install tar gcc readline-devel zlib-devel && \
 yum -y install which patch unzip && \
 yum -y install perl perl-CPAN perl-parent && \
 yum -y clean all

# PostgreSQL Version
ARG PGSQL_VERSION=9.4.10

# pgTap Version
ARG PGTAP_VERSION=0.96.0

# Database server port
ARG PGPORT=5432

# Work dir.
ARG \
 workdir=/tmp/workdir
WORKDIR \
 "${workdir}"

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
 echo "${PGUSER}:${PGPASSWORD:-$PGUSER}" |chpasswd && \
 [ -d "/home/${PGUSER}" ] || { \
  mkdir -p "/home/${PGUSER}" && \
  chown "${PGUSER}:${PGUSER}" "/home/${PGUSER}" && \
  chmod 0755 "/home/${PGUSER}"; \
 }; \
 : && { \
  echo && \
  echo '. /etc/sysconfig/postgresql' && \
  echo 'export "${PGHOME}"' && \
  echo 'export "${PGDATA}"' && \
  echo 'export PATH="${PATH}:${PGHOME}/bin"' && \
  echo; \
 } >>"/home/${PGUSER}/.bashrc"

# Install postgresql
ARG \
 PG_CONFIGURE_OPTIONS=""
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 pgname="postgresql-${PGSQL_VERSION}" && \
 pg_ver="${PGSQL_VERSION}" && \
 pg_url="https://ftp.postgresql.org/pub/source/v${pg_ver}/${pgname}.tar.gz" && \
 curl -s -o "${pgname}.tar.gz" "${pg_url}" && \
 tar -zpxvf "${pgname}.tar.gz" && \
 ( cd "${pgname}" && \
   ./configure --prefix="${PGHOME}-${pg_ver}" ${PG_CONFIGURE_OPTIONS} && \
   make && make install && \
   cd ./contrib && make && make install; ) && \
 ln -sf "${PGHOME}-${pg_ver}" "${PGHOME}-latest" && \
 rm -rf "./${pgname}"*

# Setup $PGHOME
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 mkdir -p ${PGHOME} && cd "${PGHOME}" && \
 chown -R "${PGUSER}:${PGUSER}" . && chmod -R 2755 . && \
 for dir in bin include lib share; do \
  ln -sf "${PGHOME}-latest/$dir" "$dir" || break; \
 done && \
 for dir in "${PGHOME}/archivelogs" "${PGDATA}"; do \
  { \
   mkdir -p $dir && chown "${PGUSER}:${PGUSER}" $dir && chmod 0700 $dir; \
  } || break; \
 done

# Install pgTAP
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 pgtapname="pgtap-${PGTAP_VERSION}" && \
 pgtap_ver="${PGTAP_VERSION}" && \
 pgtap_url="http://api.pgxn.org/dist/pgtap/${pgtap_ver}/${pgtapname}.zip" && \
 curl -s -o "${pgtapname}.zip" "${pgtap_url}" && \
 unzip "${pgtapname}.zip" && \
 export PATH="$PATH:${PGHOME}/bin" && \
 ( cd "${pgtapname}" && \
   make && make install; ) && \
 rm -rf "./${pgtapname}"*

# Install pg_prove
RUN \
 set -x; \
 export PERL_AUTOINSTALL='--defaultdeps' && \
 cpan -i Module::Build && \
 cpan -i TAP::Parser::SourceHandler::pgTAP && \
 rm -rf /root/.cpan

# Init database
ARG \
 PG_INITDB_OPTIONS="-E UTF-8 --locale=C"
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 su "${PGUSER}" -c "LANG= ${PGHOME}/bin/initdb ${PG_INITDB_OPTIONS} ${PGDATA}"

# Setup default config
COPY \
 db/*.conf ${workdir}/
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 for config in *.conf; do \
  [ -r "${PGDATA}/${config}" ] && \
   cp -pf "${PGDATA}/${config}"{,.ORIG}; \
  { \
   mv -f "${config}" "${PGDATA}/${config}" && \
   chown "${PGUSER}:${PGUSER}" "${PGDATA}/${config}" && \
   chmod 0644 "${PGDATA}/${config}"; \
  } || break; \
 done

# PostgreSQL Database server port
RUN \
 set -x; \
 pgsysconfig="/etc/sysconfig/postgresql" && \
 grep -E '^[ ]*PGPORT='${PGPORT}'[ ]*$' "$pgsysconfig" || { \
  echo "New PGPORT = $PGPORT."; \
  sed -i 's/^[ ]*PGPORT=[0-9]*[ ]*$/PGPORT='${PGPORT}'/g' "$pgsysconfig"; \
 } || :

# Install init script
COPY \
 pg-init.sh /etc/init.d/postgresql
RUN \
 set -x; \
 chown root:root /etc/init.d/postgresql && \
 chmod 0755 /etc/init.d/postgresql && \
 /sbin/chkconfig --add postgresql && \
 /sbin/chkconfig --levels 2345 postgresql on

# Copy pg-dbbuild script
COPY \
 pg-dbbuild.sh /root/pg-dbbuild.sh
RUN \
 set -x; \
 chown root:root /root/pg-dbbuild.sh && \
 chmod 755 /root/pg-dbbuild.sh

# Cleanup workdir
WORKDIR \
 /root
RUN \
 rm -rf "${workdir}"

# Bind port
EXPOSE "${PGPORT}"

