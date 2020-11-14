#
# centos8:*
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos8"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos8:minimal"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos8:systemd"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos8:minimal-onbuild"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} centos8:systemd-onbuild"
#

# CentOS Version
ARG CENTOS_VER="8"

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
WORKDIR /tmp/build-work

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
 : "DNF Cleanup." && { \
  dnf -v -y clean all || :; \
  [ -d "/var/cache/dnf/" ] && \
  rm -rf /var/cache/dnf/* || :; \
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


# CentOS 7 with systemd
FROM scratch AS systemd

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
WORKDIR /tmp/build-work

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
 : "DNF Cleanup." && { \
  dnf -v -y clean all || :; \
  [ -d "/var/cache/dnf/" ] && \
  rm -rf /var/cache/dnf/* || :; \
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
 name="CentOS ${CENTOS_VER} with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos${CENTOS_VER}-systemd --privileged" \
 docker.run.confirm-startup=""

# STOP SIGNAL
#STOPSIGNAL SIGINT
STOPSIGNAL SIGRTMIN+3

## Volume
#VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init" ]


# CentOS7 minimal (onbuild)
FROM minimal AS minimal-onbuild

# CentOS Version
ARG CENTOS_VER

# Set Workdir
WORKDIR /root/onbuild.d

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
WORKDIR /root/onbuild.d

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
 : "ONBUILD: DNF Cleanup." && { \
  dnf -v -y clean all || :; \
  [ -d "/var/cache/dnf/" ] && \
  rm -rf /var/cache/dnf/* || :; \
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


# CentOS 7 with systemd (onbuild)
FROM systemd AS systemd-onbuild

# CentOS Version
ARG CENTOS_VER

# Set Workdir
WORKDIR /root/onbuild.d

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
 name="CentOS ${CENTOS_VER} with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos${CENTOS_VER}-systemd --privileged" \
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
WORKDIR /root/onbuild.d

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
 : "ONBUILD: DNF Cleanup." && { \
  dnf -v -y clean all || :; \
  [ -d "/var/cache/dnf/" ] && \
  rm -rf /var/cache/dnf/* || :; \
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

