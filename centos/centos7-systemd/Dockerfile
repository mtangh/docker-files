#
# centos:centos7-systemd
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# CentOS Version
ARG CENTOS_VER="7"

# CentOS rootfs
FROM centos:centos${CENTOS_VER} AS centos7-systemd

# CentOS Version
ARG CENTOS_VER

# Set Workdir
WORKDIR /root/build

# Setup
RUN \
 set -ux; \
 : "Install systemd" && { \
  yum -v -y update && \
  yum -v -y install systemd-sysv sudo && \
  yum -v -y remove $(echo $(package-cleanup --leaves)) && \
  yum -v -y clean all && { \
   rm -rf /var/cache/yum/* || :; \
  }; \
 } && \
 : "Remove systemd files" && { \
  etc_sysd_dir="/etc/systemd/system"; \
  lib_sysd_dir="/lib/systemd/system"; \
  (cd "${etc_sysd_dir}" && { \
   rm -fv ./*.wants/* || :; \
   }; ); \
  (cd "${lib_sysd_dir}/" && { \
   : "none" || \
   rm -frv \
    sockets.target.wants/dbus.socket \
    || :; \
   rm -frv \
    anaconda.target.wants/* \
    basic.target.wants/* \
    || :; \
   rm -frv \
    local-fs.target.wants/* \
    multi-user.target.wants/* \
    sockets.target.wants/*initctl* \
    sockets.target.wants/*udev* \
    || :; \
   } && \
   cd ./sysinit.target.wants && { \
    for f in ./*; \
    do \
     [[ "${f}" =~ /systemd-tmpfiles-setup.*service$ ]] || \
     rm -fv "${f}" || :; \
    done; \
   } && \
   : "Done."; ); \
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
 name="CentOS-CentOS${CENTOS_VER} with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos-centos${CENTOS_VER}-systemd --privileged" \
 docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

# Volume
VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init" ]

