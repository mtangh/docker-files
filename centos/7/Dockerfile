#
# centos7:*
#
#@  DOCKER_IMAGEPATH="centos7"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS="${DOCKER_IMAGEPATH}:minimal"
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} ${DOCKER_IMAGEPATH}:minimal"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} ${DOCKER_IMAGEPATH}:systemd"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} ${DOCKER_IMAGEPATH}:minimal-onbuild"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} ${DOCKER_IMAGEPATH}:systemd-onbuild"
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

# YUM fastestmirror server
ARG YUM_FAST_MIRROR="www.ftp.ne.jp"
# YUM fastestmirror include domains
ARG YUM_FM_DOM_INCL=".jp,.org"
# YUM fastestmirror exclude domains
ARG YUM_FM_DOM_EXCL=""

# Enable logrotate
ARG LOGROTATION="YES"

# Enable SUDO
ARG ENABLE_SUDO="YES"

# Enable sshd
ARG ENABLE_SSHD="YES"

# RPM Packages for ONBUILD
ARG ONBUILD_RPM_PACKAGES=""

# Shell Script for ONBUILD
ARG ONBUILD_SHELL_SCRIPT=""

# CentOS rootfs
FROM centos:centos${CENTOS_VER} AS rootfs

# CentOS Version
ARG CENTOS_VER

# CentOS rootfs Image
ARG CENTOSROOT

# YUM fastestmirror server
ARG YUM_FAST_MIRROR

# YUM fastestmirror include domains
ARG YUM_FM_DOM_INCL

# YUM fastestmirror exclude domains
ARG YUM_FM_DOM_EXCL

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
COPY "000_build-chrootdir_c${CENTOS_VER}.sh" ./build-chrootdir.sh

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
 org.ugoole.options.docker.build="" \
 org.ugoole.build.template="true"


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

# COPY From root-image
COPY --from=rootfs "${CENTOSROOT}"/ /

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY shell scripts to Workdir
COPY 016_build-stage_yum.sh ./build-stage.sh
COPY \[12\]\[0-9\]\[0-9\]_*.sh ./

# SetUp
RUN \
 --mount=type=secret,id=ROOTPSWD \
 --mount=type=secret,id=DOCKER_USERS \
 set -ux; . ./build-stage.sh || exit 1;

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} Minimal" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="" \
 org.ugoole.docker.run.confirm-startup=""


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
COPY 016_build-stage_yum.sh ./build-stage.sh
COPY \[13\]\[0-9\]\[0-9\]_*.sh ./

# SetUp
RUN \
 --mount=type=secret,id=ROOTPSWD \
 --mount=type=secret,id=DOCKER_USERS \
 set -ux; . ./build-stage.sh || exit 1;

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS ${CENTOS_VER} with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h centos${CENTOS_VER}-systemd --privileged" \
 org.ugoole.docker.run.confirm-startup=""

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
COPY 016_build-stage_yum.sh ./onbuild.sh
COPY \[19\]\[0-9\]\[0-9\]_*.sh ./

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
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="" \
 org.ugoole.docker.run.confirm-startup=""

# ONBUILD: Parameters for localization
ONBUILD \
ARG \
 LANGUAGE \
 TIMEZONE \
 KEYBOARD \
 KBDTABLE

# ONBUILD: RPM Packages for ONBUILD
ONBUILD \
ARG ONBUILD_RPM_PACKAGES

# ONBUILD: Shell Script for ONBUILD
ONBUILD \
ARG ONBUILD_SHELL_SCRIPT

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: COPY contents to workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 --mount=type=secret,id=ROOTPSWD \
 --mount=type=secret,id=DOCKER_USERS \
 set -ux; scrptdir=/.onbuild && . ${scrptdir}/onbuild.sh || exit 1;

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
COPY 016_build-stage_yum.sh ./onbuild.sh
COPY \[1-9\]\[0-9\]\[0-9\]_*.sh ./

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
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h centos${CENTOS_VER}-systemd --privileged" \
 org.ugoole.docker.run.confirm-startup=""

# ONBUILD: Parameters for localization
ONBUILD \
ARG \
 LANGUAGE \
 TIMEZONE \
 KEYBOARD \
 KBDTABLE

# Enable logrotate
ONBUILD \
ARG LOGROTATION

# Enable SUDO
ONBUILD \
ARG ENABLE_SUDO

# Enable sshd
ONBUILD \
ARG ENABLE_SSHD

# ONBUILD: RPM Packages for ONBUILD
ONBUILD \
ARG ONBUILD_RPM_PACKAGES

# ONBUILD: Shell Script for ONBUILD
ONBUILD \
ARG ONBUILD_SHELL_SCRIPT

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: COPY contents to workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 --mount=type=secret,id=ROOTPSWD \
 --mount=type=secret,id=DOCKER_USERS \
 set -ux; scrptdir=/.onbuild && . ${scrptdir}/onbuild.sh || exit 1;

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

