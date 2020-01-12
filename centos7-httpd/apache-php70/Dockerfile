#
# centos7-httpd:apache-php70
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-httpd:apache-php70"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-httpd:apache

# Labels
LABEL \
 name="PHP of Apache HTTP Server on CentOS7 with Systemd" \
 maintainer="MT"

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 "${WORKDIR}"

# Remi repos URL
ARG \
 REMI_REPOS_URL=http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# Install packages for PHP
RUN \
 set -ux; \
 curl -sL -o remi.rpm "${REMI_REPOS_URL}" && \
 rpm -Uvh remi.rpm; \
 yum -v -y update && \
 yum -v -y install --enablerepo=remi-php70 php php-devel php-pear && \
 yum -v -y install --enablerepo=remi-php70 php-mbstring php-gd php-pecl-zip && \
 yum -v -y clean all

# Change the httpd.conf
RUN \
 set -ux; \
 php_ini="/etc/php.ini"; \
 [ -e "${php_ini}.ORIG" ] || { cp -pf "${php_ini}"{,.ORIG}; }; \
 echo "Update $php_ini"  && { \
  sed -ri \
   's#^(;|)[ ]*mbstring\.(internal_encoding|http_output)[ ]*=[ ]*.*$#mbstring.\2 = UTF-8#g' \
   "${php_ini}" && \
  echo; \
 } && \
 /usr/sbin/httpd -t && \
 echo;

# Reset Work dir
WORKDIR /

# Cleanup
RUN \
 set -ux; \
 for log in $(find /var/log -type f 2>/dev/null); \
 do [ -f "$log" ] && cat /dev/null 1>"$log"; done 2>/dev/null || :; \
 for log in {,/root,/tmp,/var/tmp}/*.log; \
 do rm -f "$log"; done 2>/dev/null || :; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
 rm -rf "${WORKDIR}"; } || :

#-
#- Begin ONBUILDs
#-

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

# Init
ONBUILD \
RUN \
 set -ux; \
 { [ ! -e "./etc.tgz" ] || tar -zxvf "./etc.tgz"; } && \
 { [ ! -d "./etc" ] || (cd "./etc/" && tar -cv . |tar -C /etc -xf - ); } && \
 { [ ! -e "./www.tgz" ] || tar -zxvf "./www.tgz"; } && \
 { [ ! -d "./www" ] || (cd "./www/" && tar -cv . |tar -C /var/www -xf - ); } && \
 { [ ! -e "./setup.sh" ] || /bin/bash ./setup.sh; } && \
 /usr/sbin/httpd -t && \
 echo;

# Reset Work dir
ONBUILD \
WORKDIR /

# Cleanup
ONBUILD \
RUN \
 set -x; \
 for log in $(find /var/log -type f 2>/dev/null); \
 do [ -f "$log" ] && cat /dev/null 1>"$log"; done 2>/dev/null || :; \
 for log in {,/root,/tmp,/var/tmp}/*.log; \
 do rm -f "$log"; done 2>/dev/null || :; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
 rm -rf "${WORKDIR}"; } || :

#-
#- End of ONBUILDs
#-

# Labels for run
LABEL \
 docker.run.options="-d -P -h apache-httpd-server --privileged" \
 docker.run.confirm-startup=""

