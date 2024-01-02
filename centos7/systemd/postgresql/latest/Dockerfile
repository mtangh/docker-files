#
#  centos7-systemd-postgresql
#
#@  DOCKER_IMAGEPATH="centos7-systemd-postgresql"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS=""
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}-${DOCKER_IMAGE_VER}"
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}"
#

# Logrotate
ARG LOGROTATION="YES"

# Enable SUDO
ARG ENABLE_SUDO="YES"

# SSH Login
ARG ENABLE_SSHD="YES"

# Extra RPM Packages
ARG ONBUILD_RPM_PACKAGES="postgresql postgresql-server postgresql-libs postgresql-contrib postgresql-devel postgresql-test"

# OnBuild Script
ARG ONBUILD_SHELL_SCRIPT="postgresql_onbuild.sh"

# Image fromp
FROM centos7:systemd-onbuild

# SetUp
RUN \
 set -ux; work_dir=$(pwd); \
 [ -c "$(type -P psql)" ] || { \
  echo "command 'psql' not found"; \
  exit 1; }; \
 systemctl enable postgresql

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="PostgreSQL Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h centos7-systemd-postgresql --privileged --expose=5432" \
 org.ugoole.docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

# Volume
VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init", "3" ]

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 [ ! -x "$(type -P psql)" ] || psql -l;

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: Copy contents to Workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; work_dir=$(pwd); \
 : "ONBUILD: Setup" && { \
  [ ! -e "./setup.sh" ] || \
  /bin/bash -ux -o errtrace -o functrace -o pipefail \
  ./setup.sh; \
 } && \
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y remove $(echo $( \
   package-cleanup --leaves )) || :; \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup" && { \
  cd / && [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; \
  done || :; rm -f /var/lib/rpm/__db.* || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

