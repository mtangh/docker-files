#
# centos7-lamp:lamp
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-lamp:lamp"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-httpd:apache-php

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="LAMP Environment on CentOS7 with Systemd"

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 "${WORKDIR}"

# MySQL repos URL
ARG \
 MYSQL_REPOS_URL=https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

# Install packages for MySQL
RUN \
 set -x; \
 curl -sL -o mysql57-community-release.rpm "${MYSQL_REPOS_URL}" && \
 rpm -Uvh mysql57-community-release.rpm; \
 yum -v -y update && \
 yum -v -y install mysql-community-server && \
 yum -v -y clean all

# Add service
RUN \
 set -x; \
 systemctl enable mysqld.service

# Reset Work dir
WORKDIR /

# Cleanup
RUN \
 set -x; \
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
 set -x; \
 [ ! -d "./etc" ] || { \
  (cd "./etc" && tar -cv . |tar -C /etc -xf -); \
 } && \
 [ ! -d "./www" ] || { \
  (cd "./www/" && tar -cv . |tar -C /var/www -xf -); \
 } && \
 [ ! -e "./setup.sh" ] || { \
  bash ./setup.sh && rm -f ./setup.sh; \
 } && \
 /usr/sbin/httpd -t;

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
 docker.run.options="-d -P -h lamp --privileged" \
 docker.run.confirm-startup=""

