#
# centos6-init:pg94
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:pg94"
#@  DOCKER_BUILDER_OPTS="--build-arg PGSQL_VERSION=9.4.10 --build-arg PGTAP_VERSION=0.96.0 --build-arg PGPORT=5432"
#@  DOCKER_STARTUP_OPTS="-h pg94-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD="psql -l"
#
FROM centos6-init:pg9x

# Maintainer
MAINTAINER MT

# ------------------------------
# ONBUILD
# ------------------------------

# Work dir
ONBUILD \
ARG \
 WORKDIR=/tmp/workdir
ONBUILD \
WORKDIR \
 ${WORKDIR}/db

# COPY DB CONTENTS
ONBUILD \
COPY \
 db/* ${WORKDIR}/db/

# Database build
ONBUILD \
RUN \
 set -x; \
 pgsysconfig="/etc/sysconfig/postgresql" && \
 grep -E '^[ ]*PGPORT='${PGPORT}'[ ]*$' "$pgsysconfig" || { \
  echo "New PGPORT = $PGPORT."; \
  sed -i 's/^[ ]*PGPORT=[0-9]*[ ]*$/PGPORT='${PGPORT}'/g' "$pgsysconfig"; \
 } || :

# Database build
ONBUILD \
RUN \
 set -x; . /etc/sysconfig/postgresql && \
 bash ${PGHOME}/dbbuild.sh ${WORKDIR}/db

# Cleanup
ONBUILD \
RUN \
 set -x; \
 for log in /var/log/*; do \
  cat /dev/null >"$log"; \
 done; \
 for log in /tmp/*.log; do \
  rm -f "$log"; \
 done

# Reset work dir
ONBUILD \
WORKDIR \
 /
ONBUILD \
RUN \
 rm -rf "${WORKDIR}"

# ------------------------------
# SETUP ENVIRONMENTS
# ------------------------------

# Bind port
EXPOSE "${PGPORT}"

