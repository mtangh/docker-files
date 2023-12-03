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

# SSH Login
ARG ENABLE_SSHD=""

# Logrotate
ARG LOGROTATION=""

# Extra RPM Packages
ARG ONBUILD_RPM_PACKAGES="httpd mod_ssl"

# OnBuild Script
ARG ONBUILD_SHELL_SCRIPT=""

# Apache HTTP Server on CentOS7 with Systemd
FROM centos7:systemd-onbuild

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# Copy contents to Workdir
COPY * ./

# SetUp
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "Tests" && { \
  [ -x "$(type -P httpd)" ] || { \
   echo "command 'httpd' not found." 1>&2; \
   exit 1; }; \
  echo "Remove 'welcome'." && { \
   mv -fv /usr/share/httpd/{noindex/images,icons}/poweredby.png; \
   rm -fv "/etc/httpd/conf.d/welcome.conf"; \
   rm -rfv "/usr/share/httpd/noindex"/*; \
  }; \
 } && \
 : "Update httpd.conf" && { \
  httpdcnf="/etc/httpd/conf/httpd.conf"; \
  : && { \
   [ -e "${httpdcnf}.ORIG" ] || \
   cp -pf "${httpdcnf}"{,.ORIG}; \
  } && \
  if [ -e "./httpd.conf" -a -s "./httpd.conf" ]; \
  then cat "./httpd.conf" 1>"${httpdcnf}"; \
  else \
   cat "${httpdcnf}.ORIG" | \
   sed -r \
    -e 's/^[#[:space:]]*(ServerAdmin)[[:space:]]+.*$/\1 admin@localhost/gi' \
    -e 's/^[#[:space:]]*(ServerTokens)[[:space:]]+.*$/\1 Prod/gi' \
    -e 's/^[#[:space:]]*(ServerSignature)[[:space:]]+.*$/\1 Off/gi' \
    -e 's/^[#[:space:]]*(AddDefaultCharset)[[:space:]]+.*$/\1 UTF-8/gi' \
    1>"${httpdcnf}"; \
  fi && \
  /usr/sbin/httpd -t; \
 } && \
 : "Enable httpd service." && { \
  systemctl enable httpd; \
 } && \
 : "YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; \
  done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "Done.";

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Base Image for Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-httpd-apache --privileged --expose=80 --expose=443" \
 docker.run.confirm-startup=""

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
 set -ux; \
 work_dir=$(pwd); \
 : "ONBUILD: Setup" && { \
  { [ ! -e "./etc.tgz" ] || tar -zxvf "./etc.tgz"; } && \
  { [ ! -d "./etc" ] || (cd "./etc/" && tar -cv . |tar -C /etc -xf - ); } && \
  { [ ! -e "./www.tgz" ] || tar -zxvf "./www.tgz"; } && \
  { [ ! -d "./www" ] || (cd "./www/" && tar -cv . |tar -C /var/www -xf - ); } && \
  { [ ! -e "./setup.sh" ] || /bin/bash -ux ./setup.sh; } && \
  /usr/sbin/httpd -t && \
  echo "OK"; \
 }; \
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; \
  done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

