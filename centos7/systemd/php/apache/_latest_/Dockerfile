#
# centos7s-php-apache
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos7s-php-apache:latest"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos7s-php-apache:latest-onbuild"
#

# PHP enabled Apache HTTP Server on CentOS7 with Systemd
FROM centos7s-httpd-apache:latest AS build

# PHP Packages to install
ARG PHP_PACKAGES=""

# PHP Error Reporting
ARG PHP_E_REPORT=""

# PHP Display Errors
ARG PHP_DISPERRS=""

# PHP Timezone
ARG PHP_TIMEZONE=""

# PHP MBString Language
ARG PHP_MBS_LANG=""

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# Copy contents to Workdir
COPY * ./

# SetUp
RUN \
 set -ux; \
 work_dir=$(pwd); \
 php_packages=""; \
 if [ -n "${PHP_PACKAGES:-}" ]; \
 then php_packages="${PHP_PACKAGES}"; \
 elif [ -f "./packages.txt" -a -s "./packages.txt" ]; \
 then php_packages=$(echo $(cat "./packages.txt")); \
 fi; \
 [ -n "${php_packages}" ] || { \
  php_packages="php php-pear"; \
  php_packages="${php_packages} php-mbstring php-pdo php-gd php-mcrypt php-pecl-zip"; \
  php_packages="${php_packages} php-xml php-json"; \
  echo "The PHP Package List is empty, using default: '${php_packages}''."; \
 }; \
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
 : "YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
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
 org.ugoole.options.docker.build="" \
 org.ugoole.build.template="true"


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
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h centos7s-httpd-apache-php --privileged" \
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
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h centos7s-httpd-apache-php --privileged" \
 org.ugoole.docker.run.confirm-startup=""

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
  echo; \
 }; \
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

