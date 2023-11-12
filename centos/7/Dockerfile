#
# centos7:*
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7"
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos7:minimal"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos7:systemd"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos7:minimal-onbuild"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos7:systemd-onbuild"
#

# CentOS Version
ARG CENTOS_VER="7"

# CentOS rootfs Image Dir
ARG CENTOSROOT="/centos-image/ROOT"

# Default Language
ARG LANGUAGE="en_US.UTF-8"

# Default timezone
ARG TIMEZONE="Asia/Tokyo"

# Default Keyboard Layout and key-table
ARG KEYBOARD="jp"
ARG KBDTABLE="jp106"

# root password
ARG ROOTPSWD=""

# Default user
ARG DOCKERUSER="dockeruser"
ARG DOCKERPSWD=""
ARG DOCKER_UID="500"
ARG DOCKER_GRP=""
ARG DOCKER_GID=""
ARG DOCKER_ACCOUNTNAME=""
ARG DOCKER_GROUPS_LIST=""
ARG DOCKER_USERHOMEDIR=""
ARG DOCKER_LOGIN_SHELL=""
ARG DOCKER_ENABLE_SUDO=""


# CentOS rootfs
FROM centos:centos${CENTOS_VER} AS rootfs

# CentOS Version
ARG CENTOS_VER

# CentOS rootfs Image
ARG CENTOSROOT

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
 YUM_FAST_MIRROR="${YUM_FAST_MIRROR:-}" \
 YUM_FM_DOM_INCL="${YUM_FM_DOM_INCL:-}" \
 YUM_FM_DOM_EXCL="${YUM_FM_DOM_EXCL:-}"

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY shell scripts to Workdir
COPY "00_build-chrootdir_c${CENTOS_VER}.sh" ./build-chrootdir.sh

# Setup
RUN \
 set -ux; \
 : "Execute Build Script." && { \
   /bin/bash -ux ./build-chrootdir.sh; \
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
ENV container="docker"

# CentOS Version
ARG CENTOS_VER

# CentOS rootfs Image
ARG CENTOSROOT

# Default Language
ARG LANGUAGE

# Default timezone
ARG TIMEZONE

# Default Keyboard Layout and Key-Table
ARG KEYBOARD
ARG KBDTABLE

# root password
ARG ROOTPSWD

# Default user
ARG DOCKERUSER
ARG DOCKERPSWD
ARG DOCKER_UID
ARG DOCKER_GRP
ARG DOCKER_GID
ARG DOCKER_ACCOUNTNAME
ARG DOCKER_GROUPS_LIST
ARG DOCKER_USERHOMEDIR
ARG DOCKER_LOGIN_SHELL
ARG DOCKER_ENABLE_SUDO

# COPY From root-image
COPY --from=rootfs "${CENTOSROOT}"/ /

# Set Workdir
WORKDIR /tmp/build-work

# COPY shell scripts to Workdir
COPY \[1-4\]\[0-9\]_*.sh ./

RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "Export Args." && { \
  export CENTOS_VER; \
  export LANGUAGE TIMEZONE KEYBOARD KBDTABLE; \
  export ROOTPSWD; \
  export DOCKERUSER DOCKERPSWD; \
  export DOCKER_UID DOCKER_GRP DOCKER_GID; \
  export DOCKER_ACCOUNTNAME DOCKER_GROUPS_LIST; \
  export DOCKER_USERHOMEDIR DOCKER_LOGIN_SHELL; \
  export DOCKER_ENABLE_SUDO; \
 }; \
 : "Execute Build Script." && { \
  for build_sh in ./[0-9A-Z][0-9A-Z]_*.sh; \
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
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; done || :; \
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


# CentOS with systemd
FROM scratch AS systemd

# Env
ENV container="docker"

# CentOS Version
ARG CENTOS_VER

# COPY From minimal image
COPY --from=minimal / /

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY shell scripts to Workdir
COPY \[A-Z\]\[0-9A-Z\]_*.sh ./

# SetUp
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "Export Args." && { \
  export CENTOS_VER; \
 }; \
 : "Execute Build Script." && { \
  for build_sh in ./[0-9A-Z][0-9A-Z]_*.sh; \
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
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
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


# CentOS minimal (onbuild)
FROM minimal AS minimal-onbuild

# CentOS Version
ARG CENTOS_VER

# Set Workdir
WORKDIR /.onbuild

# Copy onbuild scripts to Workdir
COPY \[1-4\]\[0-9\]_*.sh ./
COPY 9\[0-9\]_*.sh ./

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

# ONBUILD: root password
ONBUILD \
ARG ROOTPSWD=""

# ONBUILD: Default user
ONBUILD \
ARG DOCKERUSER=""
ONBUILD \
ARG DOCKERPSWD=""
ONBUILD \
ARG DOCKER_UID=""
ONBUILD \
ARG DOCKER_GRP=""
ONBUILD \
ARG DOCKER_GID=""
ONBUILD \
ARG DOCKER_ACCOUNTNAME=""
ONBUILD \
ARG DOCKER_GROUPS_LIST=""
ONBUILD \
ARG DOCKER_USERHOMEDIR=""
ONBUILD \
ARG DOCKER_LOGIN_SHELL=""
ONBUILD \
ARG DOCKER_ENABLE_SUDO=""

# ONBUILD: Extra RPM Packages
ONBUILD \
ARG RPM_PACKAGES=""

# ONBUILD: OnBuild Script
ONBUILD \
ARG ONBUILDSCRPT=""

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
 scrptdir="/.onbuild"; \
 : "ONBUILD: Export Args." && { \
  export CENTOS_VER=$(cat "${scrptdir}/CENTOS_VER"); \
  export LANGUAGE TIMEZONE KEYBOARD KBDTABLE; \
  export ROOTPSWD; \
  export DOCKERUSER DOCKERPSWD; \
  export DOCKER_UID DOCKER_GRP DOCKER_GID; \
  export DOCKER_ACCOUNTNAME DOCKER_GROUPS_LIST; \
  export DOCKER_USERHOMEDIR DOCKER_LOGIN_SHELL; \
  export DOCKER_ENABLE_SUDO; \
  export RPM_PACKAGES ONBUILDSCRPT; \
 }; \
 : "ONBUILD: Execute OnBuild Scripts." && { \
  for build_sh in "${scrptdir}"/[0-9A-Z][0-9A-Z]_*.sh; \
  do /bin/bash -ux "${build_sh}" || exit 1; done && \
  rm -rf "${scrptdir}/" || :; \
 } && \
 : "YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /


# CentOS with systemd (onbuild)
FROM systemd AS systemd-onbuild

# CentOS Version
ARG CENTOS_VER

# Set Workdir
WORKDIR /.onbuild

# Copy onbuild scripts to Workdir
COPY \[1-9\]\[0-9\]_*.sh ./

# CentOS Version
RUN \
 set -ux; \
 echo "${CENTOS_VER}" >./CENTOS_VER;

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

# ONBUILD: root password
ONBUILD \
ARG ROOTPSWD=""

# ONBUILD: Default user
ONBUILD \
ARG DOCKERUSER=""
ONBUILD \
ARG DOCKERPSWD=""
ONBUILD \
ARG DOCKER_UID=""
ONBUILD \
ARG DOCKER_GRP=""
ONBUILD \
ARG DOCKER_GID=""
ONBUILD \
ARG DOCKER_ACCOUNTNAME=""
ONBUILD \
ARG DOCKER_GROUPS_LIST=""
ONBUILD \
ARG DOCKER_USERHOMEDIR=""
ONBUILD \
ARG DOCKER_LOGIN_SHELL=""
ONBUILD \
ARG DOCKER_ENABLE_SUDO=""

# ONBUILD: sshd
ONBUILD \
ARG NO_SSH_LOGIN=""

# ONBUILD: logrotate
ONBUILD \
ARG NO_LOGMANAGE=""

# ONBUILD: Extra RPM Packages
ONBUILD \
ARG RPM_PACKAGES=""

# ONBUILD: OnBuild Script
ONBUILD \
ARG ONBUILDSCRPT=""

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
 scrptdir="/.onbuild"; \
 : "ONBUILD: Export Args." && { \
  export CENTOS_VER=$(cat "${scrptdir}/CENTOS_VER"); \
  export LANGUAGE TIMEZONE KEYBOARD KBDTABLE; \
  export ROOTPSWD; \
  export DOCKERUSER DOCKERPSWD; \
  export DOCKER_UID DOCKER_GRP DOCKER_GID; \
  export DOCKER_ACCOUNTNAME DOCKER_GROUPS_LIST; \
  export DOCKER_USERHOMEDIR DOCKER_LOGIN_SHELL; \
  export DOCKER_ENABLE_SUDO; \
  export RPM_PACKAGES ONBUILDSCRPT; \
 }; \
 : "ONBUILD: Execute OnBuild Scripts." && { \
  for build_sh in "${scrptdir}"/[0-9A-Z][0-9A-Z]_*.sh; \
  do /bin/bash -ux "${build_sh}" || exit 1; done && \
  rm -rf "${scrptdir}/" || :; \
 } && \
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -f "${lf}" -a -s "${lf}" ] && : >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

