#
# centos7-httpd:apache
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-httpd:apache"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Apache HTTP Server on CentOS7 with Systemd"

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 "${WORKDIR}"

# Install packages for Apache
RUN \
 set -x; \
 yum -v -y update && \
 yum -v -y install httpd mod-ssl && \
 yum -v -y clean all

# Change the httpd.conf
RUN \
 set -x; \
 httpd_conf="/etc/httpd/conf/httpd.conf"; \
 [ -e "${httpd_conf}.ORIG" ] || { cp -pf "${httpd_conf}"{,.ORIG}; }; \
 echo "Update $httpd_conf" && \
 sed -ri 's#^(ServerAdmin)[ ][ ]*.*$#\1 admin@localhost#g' "$httpd_conf" && \
 sed -ri 's#^(ServerTokens)[ ][ ]*.*$#\1 Prod#g' "$httpd_conf" && \
 sed -ri 's#^(ServerSignature)[ ][ ]*.*$#\1 Off#g' "$httpd_conf" && \
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
 { [ ! -e "./etc.tgz" ] || tar -zxvf "./etc.tgz"; } && \
 { [ ! -d "./etc" ] || (cd "./etc/" && tar -cv . |tar -C /etc -xf - ); } && \
 { [ ! -e "./www.tgz" ] || tar -zxvf "./www.tgz"; } && \
 { [ ! -d "./www" ] || (cd "./www/" && tar -cv . |tar -C /var/www -xf - ); } && \
 { [ ! -e "./setup.sh" ] || /bin/bash ./setup.sh; } && \
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
 docker.run.options="-d -P -h apache-httpd-server --privileged" \
 docker.run.confirm-startup=""

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 curl -sL --no-keepalive -o /dev/null "http://localhost/"

