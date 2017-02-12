#
# centos7-httpd:httpd
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-httpd:httpd"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="HTTP Server on CentOS7 with Systemd"

# Install packages for Apache (and PHP)
RUN \
 set -x; \
 yum -v -y update && \
 yum -v -y install httpd mod-ssl php php-pear php-mbstring && \
 yum -v -y clean all

# Change the httpd.conf
RUN \
 set -x; \
 httpd_conf="/etc/httpd/conf/httpd.conf"; \
 php_ini="/etc/php.ini"; \
 [ -e "${httpd_conf}.ORIG" ] || { cp -pf "${httpd_conf}"{,.ORIG}; }; \
 [ -e "${php_ini}.ORIG" ] || { cp -pf "${php_ini}"{,.ORIG}; }; \
 echo "Update $httpd_conf" && \
 sed -ri 's#^(ServerAdmin)[ ][ ]*.*$#\1 admin@localhost#g' "$httpd_conf" && \
 sed -ri 's#^(ServerTokens)[ ][ ]*.*$#\1 Prod#g' "$httpd_conf" && \
 sed -ri 's#^(ServerSignature)[ ][ ]*.*$#\1 Off#g' "$httpd_conf" && \
 echo "Update $php_ini" && \
 sed -ri \
  's#^(;|)[ ]*mbstring\.(internal_encoding|http_output)[ ]*=[ ]*.*$#mbstring.\2 = UTF-8#g' \
  "${php_ini}" && \
 /usr/sbin/httpd -t

# Add service
RUN \
 set -x; \
 systemctl enable httpd

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
 docker.run.options="-d -P -h httpd-server --privileged" \
 docker.run.confirm-startup=""

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 curl -sL --no-keepalive -o /dev/null "http://localhost/"

# Publish a container's port(s) to the host
EXPOSE 80 443

