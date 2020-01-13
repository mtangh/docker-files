#
# centos7-php:apache-php
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-php:apache-php"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-httpd:apache

# Labels
LABEL \
 name="Base image for PHP enabled Apache HTTP Server on CentOS7 with Systemd" \
 maintainer="MT"

# Reset Workdir
WORKDIR \
 /

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
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done || :; \
  [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
   cd /; rm -rf "${WORKDIR}"; } || :; \
 } 2>/dev/null || :; \
 echo;

# Reset Work dir
ONBUILD \
WORKDIR /

