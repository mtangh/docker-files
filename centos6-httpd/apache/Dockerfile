#
# centos6-httpd:apache
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-httpd:apache"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos6-upstart

# Labels
LABEL \
 name="HTTP Server on CentOS 6 with Upstart" \
 maintainer="MT"

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 "${WORKDIR}"

# Install packages for Apache (and PHP)
RUN \
 set -ux; \
 yum -v -y update && \
 yum -v -y install httpd mod-ssl && \
 yum -v -y clean all && \
 httpd_conf="/etc/httpd/conf/httpd.conf"; \
 { [ -e "${httpd_conf}.ORIG" ] || cp -pf "${httpd_conf}"{,.ORIG}; }; \
 echo "Update $httpd_conf" && { \
  sed -ri 's#^(ServerAdmin)[ ][ ]*.*$#\1 admin@localhost#g' "${httpd_conf}" && \
  sed -ri 's#^(ServerTokens)[ ][ ]*.*$#\1 Prod#g' "${httpd_conf}" && \
  sed -ri 's#^(ServerSignature)[ ][ ]*.*$#\1 Off#g' "${httpd_conf}" && \
  echo; \
 } && \
 /usr/sbin/httpd -t && \
 : "Enable httpd service." && { \
  /sbin/chkconfig --add httpd 1>/dev/null 2>&1 || :; \
  /sbin/chkconfig --levels 2345 httpd on 1>/dev/null 2>&1 || :; \
 } && \
 : "Cleanup" && { \
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done || :; \
  [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
   cd /; rm -rf "${WORKDIR}"; } || :; \
 } || :; \
 echo;

# Reset Work dir
WORKDIR /

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

#-
#- End of ONBUILDs
#-

# Labels for run
LABEL \
 docker.run.options="-d -P -h apache-httpd-server --privileged" \
 docker.run.confirm-startup=""

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 curl -sL --no-keepalive -o /dev/null "http://localhost/"

