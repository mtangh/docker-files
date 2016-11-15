#
# centos6-init:pg94
#
#
FROM centos6-init:ssh

# Install packages for PostgreSQL (and pgTAP)
RUN \
 yum -y install tar gcc readline-devel zlib-devel && \
 yum -y install patch unzip which && \
 yum -y install perl perl-CPAN perl-parent && \
 yum clean -y all

# Make DIR
RUN \
 mkdir -p /tmp/conf

# Copy RC, PG config and init script
COPY docker-pg.rc /tmp/docker-pg.rc
COPY conf/*.*     /tmp/conf/

# Create 'postgres' user and group
RUN \
 cd /tmp && . ./docker-pg.rc && \
 groupadd -g ${PG_UID:-26} ${PGUSER} && \
 useradd -u ${PG_UID:-26} -g ${PGUSER} -m ${PGUSER} && \
 echo "${PGUSER}:${PGUSER}" |chpasswd

# Install postgresql
RUN \
 cd /tmp && . ./docker-pg.rc && \
 curl -s -o /tmp/${PGSQLBASE}.tar.gz ${PGSQL_SRC} && \
 tar -C /tmp -zpxvf /tmp/${PGSQLBASE}.tar.gz && \
 cd /tmp/${PGSQLBASE} && ./configure --prefix=${PGHOME}-${PGSQL_VER} && make && make install && \
 cd ./contrib && make && make install && \
 cd /opt && \
 ln -sf ${PGHOME}-${PGSQL_VER} postgresql-latest && \
 mkdir -p ${PGHOME} && \
 cd ${PGHOME} && \
 chown -R ${PGUSER}:${PGUSER} . && chmod -R g+s . && \
 for dir in archivelogs data; do \
  mkdir -p $dir && \
  chown ${PGUSER}:${PGUSER} $dir && chmod 0700 $dir; \
 done; \
 for dir in bin include lib share; do \
  ln -sf /opt/postgresql-latest/$dir $dir; \
 done && \
 su ${PGUSER} -c "LANG= ${PGHOME}/bin/initdb -E UTF-8 --locale=C ${PGDATA}" && \
 mv -f ${PGDATA}/postgresql.conf{,.ORIG} && \
 mv -f ${PGDATA}/pg_hba.conf{,.ORIG} && \
 mv -f /tmp/conf/*.conf ${PGDATA}/ && \
 chown ${PGUSER}:${PGUSER} ${PGDATA}/{postgresql,pg_hba}.conf && \
 chmod 0644 ${PGDATA}/{postgresql,pg_hba}.conf && \
 cd /tmp && \
 mv -f /tmp/conf/postgresql.init.sh /etc/init.d/postgresql && \
 chown root:root /etc/init.d/postgresql && chmod a+x /etc/init.d/postgresql && \
 /sbin/chkconfig --add postgresql && /sbin/chkconfig --levels 2345 postgresql on && \
 rm -rf /tmp/${PGSQLBASE}* /tmp/conf

# Install pgTAP
RUN \
 cd /tmp && . ./docker-pg.rc && \
 [ -z "${PGTAP_VER}" ] || { \
   curl -s -o /tmp/${PGTAPBASE}.zip ${PGTAP_SRC} && \
   unzip /tmp/${PGTAPBASE}.zip && \
   cd /tmp/${PGTAPBASE} && \
   export PATH=$PATH:${PGHOME}/bin && make && make install && \
   rm -rf /tmp/${PGTAPBASE}*; \
 }

# Install pg_prove
RUN \
 cd /tmp && . ./docker-pg.rc && \
 [ -z "${PGTAP_VER}" ] || { \
   export PERL_AUTOINSTALL='--defaultdeps' && \
   cpan -i Module::Build && \
   cpan -i TAP::Parser::SourceHandler::pgTAP; \
 }

# Make DIR
RUN \
 mkdir -p /tmp/db

# Copy build script and db schema (and init-data)
COPY db/* /tmp/db/

# Build database
RUN \
 cd /tmp && . ./docker-pg.rc && \
 chmod a+x ./db/build.sh && ./db/build.sh && \
 rm -rf /tmp/db

# Bind port
EXPOSE 22 5480

# Start /sbin/init
CMD /sbin/init
