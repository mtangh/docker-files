#
# centos6-init:pg95
#
#@  DOCKER_TAG="centos6-init:pg95"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h pg95-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD="ps -ef|grep 'postgres: '"
#
FROM centos6-init:ssh

# Install packages for PostgreSQL (and pgTAP)
RUN \
 yum check && \
 yum -y update && \
 yum -y install tar gcc readline-devel zlib-devel && \
 yum -y install patch unzip which && \
 yum -y install perl perl-CPAN perl-parent && \
 yum clean -y all

# Copy RC, PG config and init script
COPY docker-pg.rc /root/docker-pg.rc

# Make DIR
RUN mkdir -p /tmp/conf

# PG config and init script
COPY conf/*.* /tmp/conf/

# Create 'postgres' user and group
RUN \
 . /root/docker-pg.rc && \
 groupadd -g ${PG_UID:-26} ${PGUSER} && \
 useradd -u ${PG_UID:-26} -g ${PGUSER} -m ${PGUSER} && \
 echo "${PGUSER}:${PGUSER}" |chpasswd

# Install postgresql
RUN \
 . /root/docker-pg.rc && \
 curl -s -o /tmp/${PGSQLBASE}.tar.gz ${PGSQL_SRC} && \
 tar -C /tmp -zpxvf /tmp/${PGSQLBASE}.tar.gz && \
 ( cd /tmp/${PGSQLBASE} && \
   ${PGSQLMAKECMD} ) && \
 ln -sf ${PGHOME}-${PGSQL_VER} ${PGHOME}-latest && \
 mkdir -p ${PGHOME} && \
 cd ${PGHOME} && \
 chown -R ${PGUSER}:${PGUSER} . && chmod -R 2755 . && \
 for dir in ${PGHOME}/archivelogs $(PGDATA}; do \
  mkdir -p $dir && \
  chown ${PGUSER}:${PGUSER} $dir && chmod 0700 $dir; \
 done; \
 for dir in bin include lib share; do \
  ln -sf ${PGHOME}-latest/$dir $dir; \
 done && \
 su ${PGUSER} -c "${PGSQL_INITDB}" && \
 for conf in $(cd /tmp/conf && ls -1 *.conf); do \
  [ ! -e "${PGDATA}/${conf}" ] || mv -f ${PGDATA}/${conf}{,.ORIG}; \
  [ ! -e "/tmp/conf/${conf}" ] || mv -f {/tmp/conf,$PGDATA}/${conf}; \
  chown ${PGUSER}:${PGUSER} ${PGDATA}/${conf} && \
  chmod 0644 ${PGDATA}/${conf} && \
 done; \
 mv -f /tmp/conf/postgresql.init.sh /etc/init.d/postgresql && \
 chown root:root /etc/init.d/postgresql && \
 chmod 0755 /etc/init.d/postgresql && \
 /sbin/chkconfig --add postgresql && \
 /sbin/chkconfig --levels 2345 postgresql on && \
 rm -rf /tmp/${PGSQLBASE}* /tmp/conf

# Install pgTAP
RUN \
 . /root/docker-pg.rc && \
 [ -z "${PGTAP_VER}" ] || { \
   curl -s -o /tmp/${PGTAPBASE}.zip ${PGTAP_SRC} && \
   unzip /tmp/${PGTAPBASE}.zip && \
   cd /tmp/${PGTAPBASE} && \
   export PATH=$PATH:${PGHOME}/bin && make && make install && \
   rm -rf /tmp/${PGTAPBASE}*; \
 }

# Install pg_prove
RUN \
 . /root/docker-pg.rc && \
 [ -z "${PGTAP_VER}" ] || { \
   export PERL_AUTOINSTALL='--defaultdeps' && \
   cpan -i Module::Build && \
   cpan -i TAP::Parser::SourceHandler::pgTAP; \
   rm -rf /root/.cpan; \
 }

# Make DIR
RUN mkdir -p /tmp/db

# Copy build script and db schema (and init-data)
COPY db/* /tmp/db/

# Build database
RUN \
 . /root/docker-pg.rc && \
 ( cd /tmp/db && \
   chmod 0750 ./build.sh && ./build.sh ) && \
 rm -rf /tmp/db

# Bind port
EXPOSE 22 5480

# Start /sbin/init
CMD /sbin/init
