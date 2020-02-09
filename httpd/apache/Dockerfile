#
# httpd-apache_centos7:24
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="httpd-apache_centos7:24"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:7_systemd-onbuild

# Reset Work dir
WORKDIR /

# Labels
LABEL \
 name="Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h cos7-apache-server --privileged" \
 docker.run.confirm-startup=""

# Health check
HEALTHCHECK \
 --interval=60s --timeout=15s --retries=3 \
CMD \
 curl -sL --no-keepalive -o /dev/null "http://localhost/"


# ONBUILD: Work dir
ONBUILD \
ARG WORK_DIR="/tmp/onbuild.d"
ONBUILD \
WORKDIR ${WORK_DIR}

# ONBUILD: Copy contents
ONBUILD \
COPY * "${WORK_DIR}/"

# ONBUILD: Setup
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
  cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf /root/"${WORK_DIR}" || :; \
 } && \
 echo "ONBUILD - DONE.";

# ONBUILD: Reset Work dir
ONBUILD \
WORKDIR /

