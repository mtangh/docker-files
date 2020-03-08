#
# centos:centos6-upstart
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# CentOS Version
ARG CENTOS_VER="6"

# CentOS with Upstart
FROM centos:centos${CENTOS_VER} AS centos6-upstart

# CentOS Version
ARG CENTOS_VER

# Set Workdir
WORKDIR /root/build

# Setup
RUN \
 set -ux; \
 : "Install upstart" && { \
  yum -v -y update && \
  yum -v -y install initscripts MAKEDEV sudo && \
  yum -v -y remove $(echo $(package-cleanup --leaves)) && \
  yum -v -y clean all && { \
   rm -rf /var/cache/yum/* || :; \
  }; \
 } && \
 : "Change upstart's scripts" && { \
  sed -ri 's/^/#/g' /etc/init/tty.conf && \
  sed -ri 's/wn -r now/wn -h now/g' /etc/init/control-alt-delete.conf || :; \
 } && \
 : "Rebuild RPM DB" && { \
  rpm -e --nodeps kernel || :; \
  rpm -e --nodeps kernel-firmware || :; \
  rpm --rebuilddb || :; \
 } && \
 : "Remove 'redhat-logos' files" && { \
  for clf in $(rpm -ql redhat-logos|egrep '[.](jpg|png|svg|tif)$'|sort); \
  do \
   [ -f "${clf}" ] && \
   cat /dev/null >"${clf}" || :; \
  done; \
 } && \
 : "Disable services" && { \
  for _service in iptables netfs udev-post; \
  do \
   chkconfig "${_service}" off; \
  done; \
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

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS-CentOS${CENTOS_VER} with Upstart" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos-centos6${CENTOS_VER}-upstart --privileged" \
 docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

# Start /sbin/init
CMD [ "/sbin/init", "3" ]

