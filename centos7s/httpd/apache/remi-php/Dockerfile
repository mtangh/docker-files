#
# centos7s-httpd-apache-php
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7s-httpd-apache-php"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# REMI enabled Apache HTTP Server on CentOS7 with Systemd
FROM centos7s-httpd-apache:latest AS remi-php

# REMI Repository URL
ARG REMI_PHP_REPOS_URL=""

# SetUp
RUN \
 set -ux; \
 remirepo_url="${REMI_PHP_REPOS_URL:-}"; \
 [ -n "${remirepo_url}" ] || { \
  remirepo_url="http://rpms.famillecollet.com/enterprise/remi-release-7.rpm"; \
 }; \
 : "Install remi-php.repo." && { \
  curl -sL -o remi-php-repo.rpm "${remirepo_url}" && \
  rpm -Uvh remi-php-repo.rpm && { \
  rm -f remi-php-repo.rpm || :; }; \
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
 name="REMI enabled Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 build-stage="true"


# REMI enabled Apache HTTP Server on CentOS7 with Systemd (onbuild)
FROM remi-php AS remi-php-onbuild

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="REMI enabled Apache HTTP Server on CentOS7 with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 build-stage="true"

# REMI-PHP Version
ONBUILD \
ARG REMI_PHP_VER=""

# PHP Packages to install
ONBUILD \
ARG PHP_PACKAGES=""

# PHP Error Reporting
ONBUILD \
ARG PHP_E_REPORT=""

# PHP Display Errors
ONBUILD \
ARG PHP_DISPERRS=""

# PHP Timezone
ONBUILD \
ARG PHP_TIMEZONE=""

# PHP MBString Language
ONBUILD \
ARG PHP_MBS_LANG=""

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
 remi_php_ver="${REMI_PHP_VER:-}"; \
 [ -n "${remi_php_ver:-}" ] || { \
  [ -s "./remi-php-version.txt" ] && { \
  remi_php_ver=$(head -n1 ./remi-php-version.txt); }; \
 }; \
 [ -n "${remi_php_ver:-}" ] || { \
  echo "The REMI_PHP_VER not specified, Skip this instruction."; \
  exit 0; \
 }; \
 php_packages=""; \
 if [ -n "${PHP_PACKAGES:-}" ]; \
 then php_packages="${PHP_PACKAGES}"; \
 elif [ -f "./packages.txt" -a -s "./packages.txt" ]; \
 then php_packages=$(echo $(cat "./packages.txt")); \
 else \
  php_packages="php php-devel php-pear"; \
  php_packages="${php_packages} php-mbstring php-pdo php-gd"; \
  php_packages="${php_packages} php-xml php-json php-mcrypt php-pecl-zip"; \
  echo "The REMI-PHP Package List is empty, using default: '${php_packages}'."; \
 fi; \
 : "Install REMI-PHP." && { \
  yum -v -y update && \
  yum -v -y install --enablerepo=${remi_php_ver} ${php_packages} && \
  yum -v -y clean all && { \
  rm -rf /var/cache/yum/* || :; }; \
 } && \
 : "Update php.ini" && { \
  phpinicf="/etc/php.ini"; \
  : && { \
   [ -e "${phpinicf}.ORIG" ] || \
   cp -pf "${phpinicf}"{,.ORIG}; \
  } && \
  if [ -e "./php.ini" -a -s "./php.ini" ]; \
  then cat "./php.ini" 1>"${phpinicf}"; \
  else \
   php_e_report="${PHP_E_REPORT:-E_ALL & ~E_DEPRECATED & ~E_STRICT}"; \
   php_disperrs="${PHP_DISPERRS:-On}"; \
   php_timezone="${PHP_TIMEZONE:-}"; \
   php_mbs_lang="${PHP_MBS_LANG:-Japanese}"; \
   if [ -z "${php_timezone:-}" ]; \
   then \
    php_timezone=$(readlink /etc/localtime 2>/dev/null); \
    php_timezone="${php_timezone#*/zoneinfo/}"; \
   fi; \
   cat "${phpinicf}.ORIG" | \
   sed -r \
    -e 's#(^;|^)[[:space:]]*(error_reporting)[[:space:]]*=[[:space:]]*.*$#\2 = '"${php_e_report}"'#g' \
    -e 's#(^;|^)[[:space:]]*(display_errors)[[:space:]]*=[[:space:]]*.*$#\2 = '"${php_disperrs}"'#g' \
    -e 's#(^;|^)[[:space:]]*(error_log)[[:space:]]*=[[:space:]]*(syslog)$#\2 = \3#g' \
    -e 's#(^;|^)[[:space:]]*(default_charset)[[:space:]]*=[[:space:]]*.*$#\2 = "UTF-8"#g' \
    -e 's#(^;|^)[[:space:]]*(memory_limit)[[:space:]]*=[[:space:]]*.*$#\2 = 64M#g' \
    -e 's#(^;|^)[[:space:]]*(upload_max_filesize)[[:space:]]*=[[:space:]]*.*$#\2 = 4M#g' \
    -e 's#(^;|^)[[:space:]]*(upload_max_filesize)[[:space:]]*=[[:space:]]*.*$#\2 = 4M#g' \
    -e 's#(^;|^)[[:space:]]*(expose_php)[[:space:]]*=[[:space:]]*.*$#\2 = Off#g' \
    -e 's#(^;|^)[[:space:]]*(register_argc_argv)[[:space:]]*=[[:space:]]*.*$#\2 = On#g' \
    -e 's#(^;|^)[[:space:]]*(max_execution_time)[[:space:]]*=[[:space:]]*.*$#\2 = 30#g' \
   | cat | \
   if [ -n "${php_timezone:-}" ]; \
   then sed -r \
    -e 's#(^;|^)[[:space:]]*(date[.]timezone)[[:space:]]*=[[:space:]]*.*$#\2 = "'"${php_timezone}"'"#g' \
    | cat; \
   else cat; \
   fi | \
   if rpm -qa |egrep '^([[:space:]]*php-|[[:space:]]*)mbstring' 1>/dev/null 2>&1; \
   then sed -r \
    -e 's#(^;|^)[[:space:]]*(mbstring[.]language)[[:space:]]*=[[:space:]]*.*$#\2 = '"${php_mbs_lang}"'#g' \
    -e 's#(^;|^)[[:space:]]*(mbstring[.]int.+encoding)[[:space:]]*=[[:space:]]*.*$#\2 = UTF-8#g' \
    -e 's#(^;|^)[[:space:]]*(mbstring[.]http_input)[[:space:]]*=[[:space:]]*.*$#\2 = auto#g' \
    -e 's#(^;|^)[[:space:]]*(mbstring[.]http_output)[[:space:]]*=[[:space:]]*.*$#\2 = UTF-8#g' \
    -e 's#(^;|^)[[:space:]]*(mbstring[.]enc.+translation)[[:space:]]*=[[:space:]]*.*$#\2 = On#g' \
    -e 's#(^;|^)[[:space:]]*(mbstring[.]detect_order)[[:space:]]*=[[:space:]]*.*$#\2 = auto#g' \
    | cat; \
   else cat; \
   fi | \
   cat 1>"${phpinicf}"; \
  fi && \
  /usr/sbin/httpd -t; \
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

# ONBUILD: Reset Work dir
ONBUILD \
WORKDIR /

