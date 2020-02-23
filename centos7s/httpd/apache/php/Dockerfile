#
# centos7s-httpd-apache-php
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# PHP enabled Apache HTTP Server on CentOS7 with Systemd
FROM centos7s-httpd-apache:latest AS build

# Packages to install
ARG PHP_PACKAGES=""

# Set Workdir
WORKDIR /tmp/docker-container-build

# Copy contents to Workdir
COPY * ./

# SetUp
RUN \
 set -ux; \
 php_packages=""; \
 if [ -n "${PHP_PACKAGES:-}" ]; \
 then php_packages="${PHP_PACKAGES}"; \
 elif [ -f "./packages.txt" -a -s "./packages.txt" ]; \
 then php_packages=$(echo $(cat "./packages.txt")); \
 else \
  php_packages="php php-devel php-pear"; \
  php_packages="${php_packages} php-mbstring php-pdo php-gd php-mcrypt php-pecl-zip"; \
  php_packages="${php_packages} php-xml php-json"; \
  echo "The PHP Package List is empty, using default: '${php_packages}''."; \
 fi; \
 : "Install" && { \
  yum -v -y update && \
  yum -v -y install ${php_packages} && \
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

# Reset Work dir
WORKDIR /

# Labels
LABEL \
 name="Base imaege: PHP enabled Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 build-stage="true"


# PHP enabled Apache HTTP Server on CentOS7 with Systemd
FROM scratch AS latest

# COPY From build-stage
COPY --from=build / /

# Reset Work dir
WORKDIR /

# Labels
LABEL \
 name="PHP enabled Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-httpd-apache-php --privileged" \
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


# PHP enabled Apache HTTP Server on CentOS7 with Systemd (onbuild)
FROM latest AS latest-onbuild

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="PHP enabled Apache HTTP Server on CentOS7 with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-httpd-apache-php --privileged" \
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

