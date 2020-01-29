#
# centos:7
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos:7"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# CentOS Version
ARG CENTOS_VER="7"

# CentOS rootfs Image Dir
ARG CENTOSROOT="/centos-image/rootfs"

# default System locale
ARG LANGUAGE="en_US.UTF-8"

# default keyboard laayout
ARG KBD_TYPE="jp"

# default keymap
ARG KMAPTYPE="jp106"

# default timezone
ARG TIMEZONE="Asia/Tokyo"

# root password
ARG ROOTPSWD=""


# CentOS rootfs
FROM centos:centos${CENTOS_VER} AS rootfs

# Set Workdir
WORKDIR /root

# CentOS Version
ARG CENTOS_VER

# CentOS rootfs Image
ARG CENTOSROOT

# RPM GPG Key
ARG RPM_GPGKEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${CENTOS_VER}"

# COPY rootfs-build.sh to ./rootfs-build.sh
COPY rootfs-build_centos*.sh ./

RUN \
 set -ux; \
 fsbuild_sh=./rootfs-build_centos.sh; \
 fsbuildret=0; \
 : "Execute script." && { \
  . "${fsbuild_sh}" || fsbuildret=$?; \
 }; \
 [ ${fsbuildret} -eq 0 ] && \
 echo;

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} rootfs" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 build-stage="true" \
 build-date="" \
 docker.build.options=""


# CentOS minimal
FROM scratch AS minimal

# Env
ENV container=docker

# Reset Workdir
WORKDIR /

# CentOS Version
ARG CENTOS_VER

# CentOS rootfs Image
ARG CENTOSROOT

# COPY From root-image
COPY --from=rootfs "${CENTOSROOT}"/ /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} Minimal" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 build-date="" \
 docker.build.options=""


# CentOS 7 with systemd
FROM minimal AS systemd

# Env
ENV container=docker

# Set Workdir
WORKDIR /root

# CentOS Version
ARG CENTOS_VER

# SetUp
RUN \
 set -ux; \
 : "Install systemd" && { \
  yum -v -y update && \
  yum -v -y install systemd-sysv sudo && \
  yum -v -y clean all; \
  rm -rf /var/cache/yum/*; \
 } && \
 : "Delete systemd files" && { \
  etc_sysd_sys_dir="/etc/systemd/system"; \
  usr_sysd_sys_dir="/usr/lib/systemd/system"; \
  rm -f "${etc_sysd_sys_dir}"/*.wants/*; \
  ( cd "${usr_sysd_sys_dir}/multi-user.target.wants" && { \
   for item in \
   ./dbus.service \
   ./getty.target \
   ./systemd-ask-password-wall.path \
   ./systemd-update-utmp-runlevel.service \
   ""; \
   do [ -z "${item}" ] || rm -f "${item}"; done; \
  } &>/dev/null; ); \
  ( cd "${usr_sysd_sys_dir}/sockets.target.wants" && { \
   for item in \
   ./dbus.socket \
   ./systemd-initctl.socket \
   ./systemd-udevd-control.socket \
   ./systemd-udevd-kernel.socket \
   ""; \
   do [ -z "${item}" ] || rm -f "${item}"; done; \
  } &>/dev/null; ); \
  ( cd "${usr_sysd_sys_dir}/sysinit.target.wants" && { \
   for item in \
   ./systemd-ask-password-console.path \
   ./systemd-udevd.service \
   ./systemd-udev-trigger.service \
   ./systemd-vconsole-setup.service \
   ""; \
   do [ -z "${item}" ] || rm -f "${item}"; done; \
  } &>/dev/null; ); \
  ( cd "${usr_sysd_sys_dir}/local-fs.target.wants" && { \
   for item in \
   ./systemd-remount-fs.service \
   ""; \
   do [ -z "${item}" ] || rm -f "${item}"; done; \
  } &>/dev/null; ); \
  ( cd "${usr_sysd_sys_dir}"/sysinit.target.wants && { \
   for item in *; \
   do \
    echo "${item}"| \
    egrep '^systemd-tmpfiles-setup.*service' || \
    rm -f "$item"; \
   done; \
  } &>/dev/null; ); \
 }; \
 ( : "Cleanup" && { \
  cd /; \
  for e in /var/log/*; \
  do [ -f "$e" ] && cat /dev/null 1>"$e"; done; \
  rm -f {,/var}/tmp/* /root/*; \
  yum -v -y clean all; rm -rf /var/cache/yum/*; \
 } 2>/dev/null || :; ) && \
 echo;

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 build-date="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7-systemd --privileged" \
 docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

# Volume
VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init" ]


# CentOS7 minimal (onbuild)
FROM minimal AS minimal-onbuild

# Reset Workdir
WORKDIR /

# CentOS Version
ARG CENTOS_VER

# default System locale
ARG LANGUAGE

# default keyboard laayout
ARG KBD_TYPE

# default keymap
ARG KMAPTYPE

# default timezone
ARG TIMEZONE

# root password
ARG ROOTPSWD

# Copy onbuild-i18n.sh to image root
COPY onbuild-i18n.sh /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} Minimal (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 build-date="" \
 docker.build.options="" \
 docker.run.options="" \
 docker.run.confirm-startup=""
    
# ONBUILD: OS locale
ONBUILD \
ARG CONTAINER_LANGUAGE="${LANGUAGE:-en_US.UTF-8}"

# ONBUILD: keymap
ONBUILD \
ARG CONTAINER_KMAPTYPE="${KMAPTYPE:-jp106}"

# ONBUILD: timezone
ONBUILD \
ARG CONTAINER_TIMEZONE="${TIMEZONE:-Asia/Tokyo}"

# ONBUILD: root password
ONBUILD \
ARG CONTAINER_ROOTPSWD="${ROOTPSWD:-}"

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /root

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; \
 onbuild_sh=/onbuild-i18n.sh; \
 onbuildret=0; \
 : "ONBUILD: Execute onbuild script." && { \
  . "${onbuild_sh}" || onbuildret=$?; \
 }; \
 rm -f /onbuild-*.sh || :; \
 [ ${onbuildret} -eq 0 ];

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /


# CentOS 7 with systemd (onbuild)
FROM systemd AS systemd-onbuild

# Reset Workdir
WORKDIR /

# CentOS Version
ARG CENTOS_VER

# default System locale
ARG LANGUAGE

# default keyboard laayout
ARG KBD_TYPE

# default keymap
ARG KMAPTYPE

# default timezone
ARG TIMEZONE

# root password
ARG ROOTPSWD

# Copy onbuild-*.sh to image root
COPY onbuild-*.sh /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 build-date="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos${CENTOS_VER}-systemd --privileged" \
 docker.run.confirm-startup=""

# ONBUILD: OS locale
ONBUILD \
ARG CONTAINER_LANGUAGE="${LANGUAGE:-en_US.UTF-8}"

# ONBUILD: keymap
ONBUILD \
ARG CONTAINER_KMAPTYPE="${KMAPTYPE:-jp106}"

# ONBUILD: timezone
ONBUILD \
ARG CONTAINER_TIMEZONE="${TIMEZONE:-Asia/Tokyo}"

# ONBUILD: root password
ONBUILD \
ARG CONTAINER_ROOTPSWD="${ROOTPSWD:-}"

# ONBUILD: Default login
ONBUILD \
ARG DOCKER_UID=500
ONBUILD \
ARG DOCKERUSER=dockeruser
ONBUILD \
ARG DOCKERPASS=""

# ONBUILD: sshd
ONBUILD \
ARG NO_SSH_LOGIN=""

# ONBUILD: logrotate
ONBUILD \
ARG NO_LOGROTATE=""

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /root

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; \
 onbuild_sh=/onbuild-with_systemd.sh; \
 onbuildret=0; \
 : "ONBUILD: Execute onbuild script." && { \
  . "${onbuild_sh}" || onbuildret=$?; \
 }; \
 rm -f /onbuild-*.sh || :; \
 [ ${onbuildret} -eq 0 ] && \
 echo;

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

