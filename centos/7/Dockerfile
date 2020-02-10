#
# centos:7
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos:7"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# CentOS Version
ARG CENTOS_VER="7"

# CentOS rootfs Image Dir
ARG CENTOSROOT="/centos-image/rootfs"

# root password
ARG ROOTPSWD=""

# Default Language
ARG LANGUAGE="en_US.UTF-8"

# Default keyboard layout
ARG KBD_TYPE="jp"

# Default keymap
ARG KMAPTYPE="jp106"

# Default timezone
ARG TIMEZONE="Asia/Tokyo"

# YUM Override install languages
ARG YUM_LANG="en_US.UTF-8"


# CentOS rootfs
FROM centos:centos${CENTOS_VER} AS rootfs

# Set Workdir
WORKDIR /root

# CentOS Version
ARG CENTOS_VER

# CentOS rootfs Image
ARG CENTOSROOT

# root password
ARG ROOTPSWD

# Default Language
ARG LANGUAGE

# Default keyboard layout
ARG KBD_TYPE

# Default keymap
ARG KMAPTYPE

# Default timezone
ARG TIMEZONE

# YUM Override install languages
ARG YUM_LANG

# YUM fastestmirror server
ARG YUM_FAST_MIRROR="www.ftp.ne.jp"

# YUM fastestmirror include domains
ARG YUM_FM_DOM_INCL=".jp,.org"

# YUM fastestmirror exclude domains
ARG YUM_FM_DOM_EXCL=""

# Build env
ENV CENTOS_VER="${CENTOS_VER:-}" \
    CENTOSROOT="${CENTOSROOT:-}"
ENV ROOTPSWD="${ROOTPSWD:-}" \
    LANGUAGE="${LANGUAGE}" \
    KBD_TYPE="${KBD_TYPE}" \
    KMAPTYPE="${KMAPTYPE}" \
    TIMEZONE="${TIMEZONE}" \
    YUM_LANG="${YUM_LANG}"
ENV YUM_FAST_MIRROR="${YUM_FAST_MIRROR:-}" \
    YUM_FM_DOM_INCL="${YUM_FM_DOM_INCL:-}" \
    YUM_FM_DOM_EXCL="${YUM_FM_DOM_EXCL:-}"

# Set Workdir
WORKDIR /root/build/build-chrootdir.d

# COPY shell scripts to Wirkdir
COPY 0[1-9]_*.sh 1[0-9]_*.sh ./

# Set Workdir
WORKDIR /root/build

# COPY shell scripts to Workdir
COPY 00_build-chrootdir.sh ./build-chrootdir.sh

# Setup
RUN \
 set -ux; \
 : "Execute build script." && { \
   /bin/bash -ux ./build-chrootdir.sh
 } && \
 : "Done.";

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} rootfs" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 build-stage="true"


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

# Set Workdir
ARG WORK_DIR=onbuild.d
WORKDIR /root/"${WORK_DIR}"

# root password
ARG ROOTPSWD

# Default Language
ARG LANGUAGE

# Default keyboard layout
ARG KBD_TYPE

# Default keymap
ARG KMAPTYPE

# Default timezone
ARG TIMEZONE

# YUM Override install languages
ARG YUM_LANG

# COPY shell scripts to Workdir
COPY [1-2][0-9]_*.sh ./

RUN \
 set -ux; \
 : "Execute build script." && { \
  for build_sh in ./[0-9][0-9]_*.sh; \
  do . "${build_sh}" || exit 1; done; \
 } && \
 : "Cleanup." && { \
  cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf /root/"${WORK_DIR}" || :; \
 } && \
 : "Done.";

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} Minimal" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="" \
 docker.run.confirm-startup=""


# CentOS 7 with systemd
FROM scratch AS systemd

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

# Set Workdir
ARG WORK_DIR=onbuild.d
WORKDIR /root/"${WORK_DIR}"

# root password
ARG ROOTPSWD

# Default Language
ARG LANGUAGE

# Default keyboard layout
ARG KBD_TYPE

# Default keymap
ARG KMAPTYPE

# Default timezone
ARG TIMEZONE

# YUM Override install languages
ARG YUM_LANG

# COPY shell scripts to Workdir
COPY [13][0-9]_*.sh ./

# SetUp
RUN \
 set -ux; \
 : "Execute build script." && { \
  for build_sh in ./[0-9][0-9]_*.sh; \
  do . "${build_sh}" || exit 1; done; \
 } && \
 : "Cleanup." && { \
  cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf /root/"${WORK_DIR}" || :; \
 } && \
 : "Done.";

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos${CENTOS_VER}-systemd --privileged" \
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

# root password
ARG ROOTPSWD

# Default Language
ARG LANGUAGE

# Default keyboard layout
ARG KBD_TYPE

# Default keymap
ARG KMAPTYPE

# Default timezone
ARG TIMEZONE

# Set Workdir
ARG WORK_DIR=onbuild.d
WORKDIR /root/"${WORK_DIR}"

# COPY shell scripts to Workdir
COPY [19][0-9]_*.sh ./

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} Minimal (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="" \
 docker.run.confirm-startup=""

# ONBUILD: root password
ONBUILD \
ARG ROOTPSWD="${ROOTPSWD:-}"

# ONBUILD: Language
ONBUILD \
ARG LANGUAGE="${LANGUAGE:-en_US.UTF-8}"

# ONBUILD: keyboard layout
ONBUILD \
ARG KBD_TYPE="${KBD_TYPE:-jp}"

# ONBUILD: keymap
ONBUILD \
ARG KMAPTYPE="${KMAPTYPE:-jp106}"

# ONBUILD: timezone
ONBUILD \
ARG TIMEZONE="${TIMEZONE:-Asia/Tokyo}"

# ONBUILD: Packages
ONBUILD \
ARG PACKAGES=""

# ONBUILD: Set Workdir
ONBUILD \
ARG WORK_DIR="${WORK_DIR}"
ONBUILD \
WORKDIR /root/"${WORK_DIR}"

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; \
 : "ONBUILD: Execute onbuild script." && { \
  for onbuild_sh in /root/"${WORK_DIR}"/*.sh; \
  do . "${onbuild_sh}" || exit 1; rm -f "${onbuild_sh}"; done; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf /root/"${WORK_DIR}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /


# CentOS 7 with systemd (onbuild)
FROM systemd AS systemd-onbuild

# Reset Workdir
WORKDIR /

# CentOS Version
ARG CENTOS_VER

# root password
ARG ROOTPSWD

# Default Language
ARG LANGUAGE

# Default keyboard layout
ARG KBD_TYPE

# Default keymap
ARG KMAPTYPE

# Default timezone
ARG TIMEZONE

# Set Workdir
ARG WORK_DIR="onbuild.d"
WORKDIR /root/"${WORK_DIR}"

# Copy onbuild-*.sh to Workdir
COPY [16-9][0-9]_*.sh ./

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos${CENTOS_VER}-systemd --privileged" \
 docker.run.confirm-startup=""

# ONBUILD: root password
ONBUILD \
ARG ROOTPSWD="${ROOTPSWD:-}"

# ONBUILD: Language
ONBUILD \
ARG LANGUAGE="${LANGUAGE:-en_US.UTF-8}"

# ONBUILD: keyboard layout
ONBUILD \
ARG KBD_TYPE="${KBD_TYPE:-jp}"

# ONBUILD: keymap
ONBUILD \
ARG KMAPTYPE="${KMAPTYPE:-jp106}"

# ONBUILD: timezone
ONBUILD \
ARG TIMEZONE="${TIMEZONE:-Asia/Tokyo}"

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

# ONBUILD: Packages
ONBUILD \
ARG PACKAGES=""

# ONBUILD: Set Workdir
ONBUILD \
ARG WORK_DIR="${WORK_DIR}"
ONBUILD \
WORKDIR /root/"${WORK_DIR}"

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; \
 : "ONBUILD: Execute onbuild script." && { \
  for onbuild_sh in /root/"${WORK_DIR}"/*.sh; \
  do . "${onbuild_sh}" || exit 1; rm -f "${onbuild_sh}"; done; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/* || :; \
  rm -rf /root/"${WORK_DIR}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

