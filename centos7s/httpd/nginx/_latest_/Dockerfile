#
# centos7s-httpd-nginx
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

ARG CENTOS_VER="7"

# Base Image for Nginx HTTP Server on CentOS7 with Systemd
FROM centos7s-with-ssh:latest AS build

# CentOS VERSION
ARG CENTOS_VER

# Packages to install
ARG NGINX_PKG_LIST=""
ARG NGINX_PKG_FILE="packages.txt"

# Set Workdir
WORKDIR /tmp/docker-container-build

# Copy contents to Workdir
COPY * ./

# SetUp
RUN \
 set -ux; \
 ng_rel_url="http://nginx.org/packages/centos/%V/noarch/RPMS"; \
 ng_rel_url="${ng_rel_url}/nginx-release-centos-%V-0.el%V.ngx.noarch.rpm"; \
 ng_rel_url=$(echo "${ng_rel_url}" |sed -re 's/%V/'"${CENTOS_VER:-}"'/g'); \
 packages=""; \
 if [ -n "${NGINX_PKG_LIST:-}" ]; \
 then packages="${NGINX_PKG_LIST}"; \
 elif [ -f "${NGINX_PKG_FILE:-}" -a -s "${NGINX_PKG_FILE:-}" ]; \
 then packages=$(echo $(cat "${NGINX_PKG_FILE}")); \
 fi; \
 [ -n "${packages}" ] || { \
  packages="nginx"; \
  echo "The Nginx Package List is empty, using default: '${packages}'."; \
 }; \
 : "Install" && { \
  rpm -Uvh "${ng_rel_url}" && \
  [ -e "/etc/yum.repos.d/nginx.repo" ] && { \
   sed -ri 's/^enabled=.+$/enabled=1/g' /etc/yum.repos.d/nginx.repo && \
   yum -v -y update && \
   yum -v -y install ${packages} && \
   yum -v -y clean all && { \
   rm -rf /var/cache/yum/* || :; }; \
  }; \
 } && \
 : "Update nginx.conf" && { \
  nginxcnf="/etc/nginx/nginx.conf"; \
  : && { \
   [ -e "${nginxcnf}.ORIG" ] || \
   cp -pf "${nginxcnf}"{,.ORIG}; \
  } && \
  if [ -e "./nginx.conf" -a -s "./nginx.conf" ]; \
  then cat "./nginx.conf" 1>"${nginxcnf}"; \
  else \
   cat "${nginxcnf}.ORIG" | \
   sed -r \
    -e '/^[[:space:]]*include[[:space:]]+.+mime[.]types;$/i \    server_tokens off;' \
    -e 's/^([#[:space:]]*gzip)[[:space:]]+.*;$/\1 on;/g' \
    -e '/gzip[[:space:]]/a \    server_names_hash_bucket_size 128;' \
    -e 's/^([#[:space:]]*keepalive_timeout)[[:space:]]+.*;$/\1 15;/g' \
    1>"${nginxcnf}"; \
  fi && \
  /usr/sbin/nginx -t; \
 } && \
 : "Update conf.d/default.conf" && { \
  nginxcnf="/etc/nginx/conf.d/default.conf"; \
  : && { \
   [ -e "${nginxcnf}.ORIG" ] || \
   cp -pf "${nginxcnf}"{,.ORIG}; \
  } && \
  if [ -e "./nginx-default.conf" -a -s "./nginx-default.conf" ]; \
  then cat "./nginx-default.conf" 1>"${nginxcnf}"; \
  else \
   cat "${nginxcnf}.ORIG" | \
   sed -r \
    -e 's#^([[:space:]]*root)[[:space:]]+/.*;$#\1 /var/www/html;#g' \
    1>"${nginxcnf}"; \
  fi && \
  /usr/sbin/nginx -t; \
 } && \
 : "Enable nginx service." && { \
  systemctl enable nginx; \
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

# Labels
LABEL \
 name="Base Image for Nginx HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 build-stage="true"


# Nginx HTTP Server on CentOS7 with Systemd
FROM scratch AS latest

# COPY From build-stage
COPY --from=build / /

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Nginx HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-httpd-nginx --privileged" \
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


# Nginx HTTP Server on CentOS7 with Systemd (onbuild)
FROM latest AS latest-onbuild

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Nginx HTTP Server on CentOS7 with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-httpd-nginx --privileged" \
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

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

