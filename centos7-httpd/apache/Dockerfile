#
# centos7-httpd:apache
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-httpd:apache"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Labels
LABEL \
 name="Base image for Apache HTTP Server on CentOS7 with Systemd" \
 maintainer="MT"

# Work dir
ONBUILD \
ARG \
 WORKDIR=/tmp/workdir
ONBUILD \
WORKDIR \
 "${WORKDIR}"

# Copy contents
ONBUILD \
COPY \
 * "${WORKDIR}/"

# Install packages for Apache
ONBUILD \
ARG \
 APACHE_PKG_LIST="./packages.txt"
ONBUILD \
RUN \
 set -ux; \
 if [ -n "${APACHE_PKG_LIST:-}" -a -s "${APACHE_PKG_LIST:-}" ]; \
 then \
  packages=$(echo $(cat "${APACHE_PKG_LIST}")); \
 else \
  packages="httpd mod_ssl"; \
  echo "The Apache Package List is empty, using default: '${packages}''." 1>&2; \
 fi; \
 : "ONUILD: Install Apache Packages" && { \
  yum -v -y update && \
  yum -v -y install ${packages} && \
  yum -v -y clean all && \
  echo; \
 } && \
 httpdcnf="/etc/httpd/conf/httpd.conf"; \
 : "ONUILD: Update ${httpdcnf}" && { \
  { [ -e "${httpdcnf}.ORIG" ] || cp -pf "${httpdcnf}"{,.ORIG}; }; \
  if [ -e "./httpd.conf" -a -s "./httpd.conf" ]; \
  then \
   cat "./httpd.conf" 1>"${httpdcnf}"; \
  else \
   sed -ri 's#^(ServerAdmin)[ ][ ]*.*$#\1 admin@localhost#g' "${httpdcnf}" && \
   sed -ri 's#^(ServerTokens)[ ][ ]*.*$#\1 Prod#g' "${httpdcnf}" && \
   sed -ri 's#^(ServerSignature)[ ][ ]*.*$#\1 Off#g' "${httpdcnf}" && \
   echo; \
  fi && \
  /usr/sbin/httpd -t; \
 } && \
 : "Enable httpd service." && { \
   systemctl enable httpd; \
 } && \
 : "Cleanup" && { \
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

