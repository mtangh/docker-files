#
# httpd-apache_centos7
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="httpd-apache_centos7"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# Workdir
ARG WORK_DIR="httpd-apache-build"

# Apache HTTP Server on CentOS7 with Systemd
FROM centos:7_systemd-onbuild AS latest

# Apache package list
ARG PACKAGE_LIST=""

# Workdir
ARG WORK_DIR

# Set Workdir
WORKDIR /tmp/"${WORK_DIR}"

# COPY shell scripts to Workdir
COPY * ./

# SetUp
RUN \
 set -ux; \
 packages=""; \
 if [ -n "${PACKAGE_LIST:-}" ]; \
 then packages="${PACKAGE_LIST}"; \
 elif [ -f "./packages.txt" -a -s "./packages.txt" ]; \
 then packages=$(echo $(cat "./packages.txt")); \
 else \
  packages="httpd mod_ssl"; \
  echo "The Apache Package List is empty, using default: '${packages}''."; \
 fi; \
 : "Install Apache Packages" && { \
  yum -v -y update && \
  yum -v -y install ${packages} && \
  yum -v -y clean all; \
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
    -e 's#^(ServerAdmin)[ ][ ]*.*$#\1 admin@localhost#g' \
    -e 's#^(ServerTokens)[ ][ ]*.*$#\1 Prod#g' \
    -e 's#^(ServerSignature)[ ][ ]*.*$#\1 Off#g' \
    1>"${httpdcnf}"; \
  fi && \
  /usr/sbin/httpd -t; \
 } && \
 : "Enable httpd service." && { \
  systemctl enable httpd; \
 } && \
 : "Cleanup." && { \
  cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf /tmp/"${WORK_DIR}" || :; \
 } && \
 : "Done.";

# Reset Work dir
WORKDIR /

# Labels
LABEL \
 name="Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h httpd-apache-cos7sysd --privileged" \
 docker.run.confirm-startup=""

# Health check
HEALTHCHECK \
 --interval=60s --timeout=15s --retries=3 \
CMD \
 curl -sL --no-keepalive -o /dev/null "http://localhost/"


# Apache HTTP Server on CentOS7 with Systemd (onbuild)
FROM latest AS latest-onbuild

# Workdir
ARG WORK_DIR

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Apache HTTP Server on CentOS7 with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h httpd-apache-cos7sysd --privileged" \
 docker.run.confirm-startup=""

# ONBUILD: Set Workdir
ONBUILD \
ARG WORK_DIR="${WORK_DIR}"
ONBUILD \
WORKDIR /tmp/"${WORK_DIR}"

# ONBUILD: Copy Contents
ONBUILD \
COPY * /tmp/"${WORK_DIR}"

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
  cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf /tmp/"${WORK_DIR}"/ || :; \
 } && \
 echo "ONBUILD - DONE.";

# ONBUILD: Reset Work dir
ONBUILD \
WORKDIR /

