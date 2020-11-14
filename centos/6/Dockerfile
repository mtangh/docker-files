#
# centos6:*
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos6"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos6:minimal"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos6:upstart"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos6:minimal-onbuild"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos6:upstart-onbuild"
#

# CentOS Version
ARG CENTOS_VER="6"

# CentOS rootfs Image Dir
ARG CENTOSROOT="/centos-image/ROOT"

# root password
ARG ROOTPSWD=""

# Default Language
ARG LANGUAGE="en_US.UTF-8"

# Default timezone
ARG TIMEZONE="Asia/Tokyo"

# Default Keyboard Layout and key-table
ARG KEYBOARD="jp"
ARG KBDTABLE="jp106"


# CentOS rootfs
FROM centos:centos${CENTOS_VER} AS rootfs

# CentOS Version
ARG CENTOS_VER

# CentOS rootfs Image
ARG CENTOSROOT

# root password
ARG ROOTPSWD

# Default Language
ARG LANGUAGE

# Default timezone
ARG TIMEZONE

# Default Keyboard Layout and Key-Table
ARG KEYBOARD
ARG KBDTABLE

# YUM fastestmirror server
ARG YUM_FAST_MIRROR="www.ftp.ne.jp"

# YUM fastestmirror include domains
ARG YUM_FM_DOM_INCL=".jp,.org"

# YUM fastestmirror exclude domains
ARG YUM_FM_DOM_EXCL=""

# Build env
ENV \
 CENTOS_VER="${CENTOS_VER:-}" \
 CENTOSROOT="${CENTOSROOT:-}"

ENV \
 ROOTPSWD="${ROOTPSWD:-}" \
 LANGUAGE="${LANGUAGE:-}" \
 TIMEZONE="${TIMEZONE:-}" \
 KEYBOARD="${KEYBOARD:-}" \
 KBDTABLE="${KBDTABLE:-}"

ENV \
 YUM_FAST_MIRROR="${YUM_FAST_MIRROR:-}" \
 YUM_FM_DOM_INCL="${YUM_FM_DOM_INCL:-}" \
 YUM_FM_DOM_EXCL="${YUM_FM_DOM_EXCL:-}"

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY shell scripts to Workdir
COPY 00_build-chrootdir.sh ./build-chrootdir.sh

# Setup
RUN \
 set -ux; \
 : "Execute Build Script." && { \
   /bin/bash -ux ./build-chrootdir.sh; \
 } && \
 : "Done.";

## Set Workdir
#WORKDIR /tmp/docker-container-image-build/scripts.d
#
## COPY shell scripts to Workdir
#COPY 1\[0-9\]_*.sh ./
#
## Setup (Ph2)
#RUN \
# set -ux; \
# : "Chroot to the environment and install some additional tools." && { \
#  cp -pf {,"${CENTOSROOT}"}/etc/resolv.conf && { \
#    for build_sh in ./[0-9][0-9]_*.sh; \
#    do \
#      [ -e "${build_sh}" ] && \
#      chroot "${CENTOSROOT}" /bin/bash -ux <"${build_sh}" || \
#      exit 1; \
#    done; \
#  } && \
#  rm -f "${CENTOSROOT}/etc/resolv.conf" || :; \
# } && \
# : "Done.";

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
ENV container="docker"

# CentOS Version
ARG CENTOS_VER

# CentOS rootfs Image
ARG CENTOSROOT

# root password
ARG ROOTPSWD

# Default Language
ARG LANGUAGE

# Default timezone
ARG TIMEZONE

# Default Keyboard Layout and Key-Table
ARG KEYBOARD
ARG KBDTABLE

# COPY From root-image
COPY --from=rootfs "${CENTOSROOT}"/ /

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY shell scripts to Workdir
COPY \[12\]\[0-9\]_*.sh ./

RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "Export Args." && { \
  export CENTOS_VER; \
  export ROOTPSWD; \
  export LANGUAGE TIMEZONE KEYBOARD KBDTABLE; \
 }; \
 : "Execute Build Script." && { \
  for build_sh in ./[0-9][0-9]_*.sh; \
  do /bin/bash -ux "${build_sh}" || exit 1; done; \
 } && \
 : "YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
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


# CentOS 6 with upstart
FROM scratch AS upstart

# Env
ENV container="docker"

# CentOS Version
ARG CENTOS_VER

# CentOS rootfs Image
ARG CENTOSROOT

# root password
ARG ROOTPSWD

# Default Language
ARG LANGUAGE

# Default timezone
ARG TIMEZONE

# Default Keyboard Layout and Key-Table
ARG KEYBOARD
ARG KBDTABLE

# COPY From root-image
COPY --from=rootfs "${CENTOSROOT}"/ /

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY shell scripts to Workdir
COPY \[13\]\[0-9\]_*.sh ./

# SetUp
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "Export Args." && { \
  export CENTOS_VER; \
  export ROOTPSWD; \
  export LANGUAGE TIMEZONE KEYBOARD KBDTABLE; \
 }; \
 : "Execute Build Script." && { \
  for build_sh in ./[0-9][0-9]_*.sh; \
  do /bin/bash -ux "${build_sh}" || exit 1; done; \
 } && \
 : "YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "Done.";

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} with Upstart" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos${CENTOS_VER}-upstart --privileged" \
 docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

# Volume
VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init", "3" ]


# CentOS7 minimal (onbuild)
FROM minimal AS minimal-onbuild

# CentOS Version
ARG CENTOS_VER

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# Copy onbuild scripts to Workdir
COPY \[19\]\[0-9\]_*.sh ./

# CentOS Version
RUN \
 set -ux; \
 echo "${CENTOS_VER}" >./CENTOS_VER;

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
ARG ROOTPSWD=""

# ONBUILD: Language
ONBUILD \
ARG LANGUAGE=""

# ONBUILD: timezone
ONBUILD \
ARG TIMEZONE=""

# ONBUILD: Keyboard Layout and Key-Table
ONBUILD \
ARG KEYBOARD=""
ONBUILD \
ARG KBDTABLE=""

# ONBUILD: Extra RPM Packages
ONBUILD \
ARG RPM_PACKAGES=""

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: COPY contents to workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "ONBUILD: Export Args." && { \
  export CENTOS_VER=$(cat ./CENTOS_VER); \
  export ROOTPSWD; \
  export LANGUAGE TIMEZONE KEYBOARD KBDTABLE; \
  export RPM_PACKAGES; \
 }; \
 : "ONBUILD: Execute OnBuild Scripts." && { \
  for build_sh in ./[0-9][0-9]_*.sh; \
  do /bin/bash -ux "${build_sh}" || exit 1; done; \
 } && \
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /


# CentOS 6 with upstart (onbuild)
FROM upstart AS upstart-onbuild

# CentOS Version
ARG CENTOS_VER

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# Copy onbuild scripts to Workdir
COPY \[16-9\]\[0-9\]_*.sh ./

# CentOS Version
RUN \
 set -ux; \
 echo "${CENTOS_VER}" >./CENTOS_VER;

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} with Upstart (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos${CENTOS_VER}-upstart --privileged" \
 docker.run.confirm-startup=""

# ONBUILD: root password
ONBUILD \
ARG ROOTPSWD=""

# ONBUILD: Language
ONBUILD \
ARG LANGUAGE=""

# ONBUILD: timezone
ONBUILD \
ARG TIMEZONE=""

# ONBUILD: Keyboard Layout and Key-Table
ONBUILD \
ARG KEYBOARD=""
ONBUILD \
ARG KBDTABLE=""

# ONBUILD: Default login
ONBUILD \
ARG DOCKER_UID=""
ONBUILD \
ARG DOCKERUSER=""
ONBUILD \
ARG DOCKERPASS=""

# ONBUILD: sshd
ONBUILD \
ARG NO_SSH_LOGIN=""

# ONBUILD: logrotate
ONBUILD \
ARG NO_LOGMANAGE=""

# ONBUILD: Extra RPM Packages
ONBUILD \
ARG RPM_PACKAGES=""

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: COPY contents to workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "ONBUILD: Export Args." && { \
  export CENTOS_VER=$(cat ./CENTOS_VER); \
  export ROOTPSWD; \
  export LANGUAGE TIMEZONE KEYBOARD KBDTABLE; \
  export DOCKER_UID DOCKERUSER DOCKERPASS; \
  export NO_SSH_LOGIN NO_LOGMANAGE; \
  export RPM_PACKAGES; \
 }; \
 : "ONBUILD: Execute OnBuild Scripts." && { \
  for build_sh in ./[0-9][0-9]_*.sh; \
  do /bin/bash -ux "${build_sh}" || exit 1; done; \
 } && \
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

