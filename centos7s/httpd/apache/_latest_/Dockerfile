#
#  centos7s-httpd-apache
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# Base Image for Apache HTTP Server on CentOS7 with Systemd
FROM centos7s-with-ssh:latest AS build

# Packages to install
ARG PACKAGES=""

# Set Workdir
WORKDIR /tmp/docker-container-build

# Copy contents to Workdir
COPY * ./

# SetUp
RUN \
 set -ux; \
 packages=""; \
 if [ -n "${PACKAGES:-}" ]; \
 then packages="${PACKAGES}"; \
 elif [ -f "./packages.txt" -a -s "./packages.txt" ]; \
 then packages=$(echo $(cat "./packages.txt")); \
 else \
  packages="httpd mod_ssl"; \
  echo "The Apache Package List is empty, using default: '${packages}'."; \
 fi; \
 : "Install" && { \
  yum -v -y update && \
  yum -v -y install ${packages} && \
  yum -v -y clean all && { \
  rm -rf /var/cache/yum/* || :; }; \
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
 : "Cleanup." && { \
  work_dir=$(pwd); cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf "${work_dir}" || :; \
 } && \
 : "Done.";

# Reset Work dir
WORKDIR /

# Labels
LABEL \
 name="Base Image for Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 build-stage="true"


# Apache HTTP Server on CentOS7 with Systemd
FROM scratch AS latest

# COPY From build-stage
COPY --from=build / /

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-httpd-apache --privileged" \
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


# Apache HTTP Server on CentOS7 with Systemd (onbuild)
FROM latest AS latest-onbuild

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Apache HTTP Server on CentOS7 with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-httpd-apache --privileged" \
 docker.run.confirm-startup=""

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-build

# ONBUILD: Copy contents to Workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; \
 : "ONBUILD: Setup" && { \
  { [ ! -e "./etc.tgz" ] || tar -zxvf "./etc.tgz"; } && \
  { [ ! -d "./etc" ] || (cd "./etc/" && tar -cv . |tar -C /etc -xf - ); } && \
  { [ ! -e "./www.tgz" ] || tar -zxvf "./www.tgz"; } && \
  { [ ! -d "./www" ] || (cd "./www/" && tar -cv . |tar -C /var/www -xf - ); } && \
  { [ ! -e "./setup.sh" ] || /bin/bash -ux ./setup.sh; } && \
  /usr/sbin/httpd -t && \
  echo; \
 }; \
 : "ONBUILD: Cleanup" && { \
  work_dir=$(pwd); cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf "${work_dir}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Work dir
ONBUILD \
WORKDIR /

