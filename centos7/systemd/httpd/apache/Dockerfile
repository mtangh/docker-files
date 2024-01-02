#
#  centos7-systemd-httpd:apache
#
#@  DOCKER_IMAGEPATH="centos7-systemd-httpd:apache"
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
ARG ONBUILD_RPM_PACKAGES="httpd mod_ssl"

# OnBuild Script
ARG ONBUILD_SHELL_SCRIPT="httpd-apache_onbuild.sh"

# Image fromp
FROM centos7:systemd-onbuild

# SetUp
RUN \
 set -ux; work_dir=$(pwd); \
 [ -x "$(type -P httpd)" ] || { \
  echo "command 'httpd' not found"; \
  exit 1; }; \
 systemctl enable httpd

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h centos7-systemd-httpd-apache --privileged --expose=80 --expose=443" \
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
 curl -sL --no-keepalive -o /dev/null "http://localhost/"

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
  { [ ! -e "./etc.tgz" ] || tar -zxvf "./etc.tgz"; } && \
  { [ ! -d "./etc" ] || (cd "./etc/" && tar -cv . |tar -C /etc -xf - ); } && \
  { [ ! -e "./www.tgz" ] || tar -zxvf "./www.tgz"; } && \
  { [ ! -d "./www" ] || (cd "./www/" && tar -cv . |tar -C /var/www -xf - ); } && \
  : "Run setup" && { \
   [ ! -e "./setup.sh" ] || \
   /bin/bash -ux -o errtrace -o functrace -o pipefail \
   ./setup.sh; \
  } && \
  /usr/sbin/httpd -t && \
  echo "OK"; \
 }; \
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

