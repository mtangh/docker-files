#
# centos6-init:pg9x
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:pg9x"
#@  DOCKER_BUILDER_OPTS=""
#@  DOCKER_STARTUP_OPTS="-h pg9x"
#@  CONTAINER_NOT_START="yes"
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:ssh

# Maintainer
MAINTAINER MT

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 "${WORKDIR}"

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
  echo && \
  echo '# For PostgreSQL' && \
  echo 'if [ -r "/etc/sysconfig/postgresql" ]' && \
  echo 'then' && \
  echo '  . /etc/sysconfig/postgresql' && \
  echo '  export PGUSER PGHOME PGDATA PGPORT' && \
  echo 'fi' && \
  echo '[ -n "${PGHOME}" ] &&' && \
  echo '[ -d "${PGHOME}/bin" ] &&' && \
  echo '[ -z "$(type -p psql)" ] &&' && \
  echo 'export PATH="${PATH}:${PGHOME}/bin"' && \
  echo; \
 } >>"${PGHOME}/.bashrc"

# Install init and db build script
COPY \
 pg-*.sh ${WORKDIR}/
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 mv -f "${WORKDIR}/pg-init.sh" "/etc/init.d/postgresql" && \
 chown root:root /etc/init.d/postgresql && \
 chmod 0755 /etc/init.d/postgresql && \
 mv -f "${WORKDIR}/pg-dbbuild.sh" "${PGHOME}/dbbuild.sh" && \
 chown "root:${PGUSER}" "${PGHOME}/dbbuild.sh" && \
 chmod 0775 "${PGHOME}/dbbuild.sh"

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in /tmp/*.log; do rm -f "$log"; done

# Health check
HEALTHCHECK \
--interval=30s --timeout=15s --retries=3 \
CMD \
 . /etc/sysconfig/postgresql; \
 [ ! -x "${PGHOME}/bin/psql" ] || su - "${PGUSER}" -c 'psql -l';

# Reset Work dir
WORKDIR \
 /
RUN \
 rm -rf "${WORKDIR}"

