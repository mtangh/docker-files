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

# PHP Packages
ONBUILD \
ARG PHP_PACKAGES=""

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
   cat "${phpinicf}.ORIG" | \
   if rpm -qa |egrep '^([ ]*php-|[ ]*)mbstring'; \
   then sed -r -e \
    's#^(;|)[ ]*(mbstring)\.(internal_encoding|http_output)[ ]*=[ ]*.*$#\2.\3 = UTF-8#g'; \
   else cat; \
   fi |cat 1>"${phpinicf}"; \
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

