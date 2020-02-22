#
# centos7sysd-httpd-apache-php
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7sysd-httpd-apache:latest AS base

# Reset Work dir
WORKDIR /

# Labels
LABEL \
 name="Nginx HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7sysd-httpd-nginx --privileged" \
 docker.run.confirm-startup=""

# Work dir
ONBUILD \
ARG \
 WORKDIR="/tmp/workdir"
ONBUILD \
WORKDIR \
 ${WORKDIR}

# Copy contents
ONBUILD \
COPY \
 * "${WORKDIR}/"

# Setup
ONBUILD \
RUN \
 set -ux; \
 : "ONBUILD: Install PHP Packages" && { \
  if [ -e "./install.sh" ]; \
  then bash ./install.sh; \
  else \
   yum -v -y update && \
   yum -v -y install php php-devel php-pear && \
   yum -v -y install php-mbstring php-pdo php-gd php-xml php-json php-mcrypt php-pecl-zip && \
   yum -v -y clean all && \
   echo; \
  fi && \
  php_ini_file="/etc/php.ini"; \
  : "Update ${php_ini_file}" && { \
   { [ -e "${php_ini_file}.ORIG" ] || cp -pf "${php_ini_file}"{,.ORIG}; }; \
   if [ -e "./php.ini" -a -s "./php.ini" ]; \
   then \
    cat "./php.ini" 1>"${php_ini_file}"; \
   else \
    sed -ri \
    's#^(;|)[ ]*mbstring\.(internal_encoding|http_output)[ ]*=[ ]*.*$#mbstring.\2 = UTF-8#g' \
    "${php_ini_file}" && \
    echo; \
   fi && \
   /usr/sbin/httpd -t && \
   echo; \
  }; \
 } && \
 : "ONBUILD: Cleanup" && { \
  work_dir=$(pwd); cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf "${work_dir}" || :; \
 } && \
 : "ONBUILD: Done.";

# Reset Work dir
ONBUILD \
WORKDIR /

