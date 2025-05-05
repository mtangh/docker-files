#
# almalinux8:*
#
#@  DOCKER_IMAGEPATH="almalinux8"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS="${DOCKER_IMAGEPATH}:minimal"
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} ${DOCKER_IMAGEPATH}:minimal"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} ${DOCKER_IMAGEPATH}:minimal-onbuild"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} ${DOCKER_IMAGEPATH}:init"
#@  DOCKER_PUBLISHED="${DOCKER_PUBLISHED} ${DOCKER_IMAGEPATH}:init-onbuild"
#

# AlmaLinux Version
ARG ALMALINUX_VER="8"

# AlmaLinux rootfs Image Dir
ARG ALMALINUXROOT="/almalinux-image/ROOT"

# Install EPEL Repo
ARG INSTALLEPEL="YES"

# Default Language
ARG LANGUAGE="C.UTF-8"

# Default timezone
ARG TIMEZONE="Asia/Tokyo"

# Default Keyboard Layout and key-table
ARG KEYBOARD="jp"
ARG KBDTABLE="jp106"

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


# AlmaLinux minimal-builder
FROM almalinux:${ALMALINUX_VER}-minimal AS build-stage_base

# AlmaLinux Version / Image Dir / EPEL
ARG \
 ALMALINUX_VER \
 ALMALINUXROOT \
 INSTALLEPEL

# Build env
ENV \
 ALMALINUX_VER="${ALMALINUX_VER:-}" \
 ALMALINUXROOT="${ALMALINUXROOT:-}" \
 INSTALLEPEL="${INSTALLEPEL:-}"

# Set Workdir
WORKDIR /.docker-container-image-build

# COPY shell scripts to Workdir
COPY "000_build-chrootdir_alma${ALMALINUX_VER}.sh" ./build-chrootdir_base.sh

# Setup
RUN \
 : "Execute Build Script." && { \
  set -ux -o errtrace -o functrace -o pipefail; \
  work_dir="$(pwd)"; \
  /bin/bash -ux ./build-chrootdir_base.sh || exit $?; \
  cd /; rm -rf "${work_dir}" || :; \
 } && \
 : "Done.";

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} Builder-Base" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.build.template="true"


# AlmaLinux minimal-builder
FROM scratch AS build-stage_minimal

# AlmaLinux Version / Image Dir / EPEL
ARG \
 ALMALINUX_VER \
 ALMALINUXROOT \
 INSTALLEPEL

# Build env
ENV \
 ALMALINUX_VER="${ALMALINUX_VER:-}" \
 ALMALINUXROOT="${ALMALINUXROOT:-}" \
 INSTALLEPEL="${INSTALLEPEL:-}"

# COPY From base image
COPY --from=build-stage_base / /

# Set Workdir
WORKDIR /.docker-container-image-build

# COPY shell scripts to Workdir
COPY "001_build-chrootdir_alma${ALMALINUX_VER}-minimal.sh" ./build-chrootdir_stage.sh

# Setup
RUN \
 : "Execute Build Script." && { \
  set -ux -o errtrace -o functrace -o pipefail; \
  work_dir="$(pwd)"; \
  /bin/bash -ux ./build-chrootdir_stage.sh || exit $?; \
  cd /; rm -rf "${work_dir}" || :; \
 } && \
 : "Done.";

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} Base-image for building Minilmal." \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.build.template="true"


# AlmaLinux minimal-builder
FROM scratch AS build-stage_init

# AlmaLinux Version / Image Dir / EPEL
ARG \
 ALMALINUX_VER \
 ALMALINUXROOT \
 INSTALLEPEL

# Build env
ENV \
 ALMALINUX_VER="${ALMALINUX_VER:-}" \
 ALMALINUXROOT="${ALMALINUXROOT:-}" \
 INSTALLEPEL="${INSTALLEPEL:-}"

# COPY From base image
COPY --from=build-stage_minimal / /

# Set Workdir
WORKDIR /.docker-container-image-build

# COPY shell scripts to Workdir
COPY "002_build-chrootdir_alma${ALMALINUX_VER}-init.sh" ./build-chrootdir_stage.sh

# Setup
RUN \
 : "Execute Build Script." && { \
  set -ux -o errtrace -o functrace -o pipefail; \
  work_dir="$(pwd)"; \
  /bin/bash -ux ./build-chrootdir_stage.sh || exit $?; \
  cd /; rm -rf "${work_dir}" || :; \
 } && \
 : "Done.";

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} Base-image for building Init." \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.build.template="true"


# AlmaLinux minimal
FROM scratch AS minimal

# Env
ENV container="docker"

# AlmaLinux Version / Image Dir / EPEL
ARG \
 ALMALINUX_VER \
 ALMALINUXROOT \
 INSTALLEPEL

# Parameters for localization
ARG \
 LANGUAGE \
 TIMEZONE \
 KEYBOARD \
 KBDTABLE

# COPY From root-image
COPY --from=build-stage_minimal "${ALMALINUXROOT}"/ /

# Set Workdir
WORKDIR /.onbuild

# COPY shell scripts to Workdir
COPY 020_build-stage_alma.sh ./build-stage.sh
COPY \[1-5\]\[0-9\]\[0-9\]_*.sh ./

# SetUp
RUN \
 --mount=type=secret,id=ROOTPSWD \
 --mount=type=secret,id=DOCKER_USERS \
 set -ux -o errtrace -o functrace -o pipefail; . ./build-stage.sh || exit $?;

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} Minimal" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="" \
 org.ugoole.docker.run.confirm-startup=""

# Start /bin/bash
CMD [ "/bin/bash" ]


# AlmaLinux minimal (onbuild)
FROM minimal AS minimal-onbuild

# AlmaLinux Version
ARG ALMALINUX_VER

# Set Workdir
WORKDIR /.onbuild

# Copy onbuild scripts to Workdir
COPY 020_build-stage_alma.sh ./onbuild-stage.sh
COPY \[1-59\]\[0-9\]\[0-9\]_*.sh ./

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} Minimal (onbuild)" \
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

# ONBUILD: RPM Packages and Shell Scripts for ONBUILD
ONBUILD \
ARG \
 ONBUILD_RPM_PACKAGES \
 ONBUILD_SHELL_SCRIPT

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /.onbuild

# ONBUILD: COPY contents to workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 --mount=type=secret,id=ROOTPSWD \
 --mount=type=secret,id=DOCKER_USERS \
 set -ux -o errtrace -o functrace -o pipefail; . ./onbuild-stage.sh || exit $?;

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /


# AlmaLinux with init
FROM scratch AS init

# Env
ENV container="docker"

# AlmaLinux Version / Image Dir / EPEL
ARG \
 ALMALINUX_VER \
 ALMALINUXROOT \
 INSTALLEPEL

# Parameters for localization
ARG \
 LANGUAGE \
 TIMEZONE \
 KEYBOARD \
 KBDTABLE

# COPY From minimal image
COPY --from=build-stage_init "${ALMALINUXROOT}"/ /

# Set Workdir
WORKDIR /.onbuild

# COPY shell scripts to Workdir
COPY 020_build-stage_alma.sh ./build-stage.sh
COPY \[1-5\]\[0-9\]\[0-9\]_*.sh ./

# SetUp
RUN \
 --mount=type=secret,id=ROOTPSWD \
 --mount=type=secret,id=DOCKER_USERS \
 set -ux -o errtrace -o functrace -o pipefail; . ./build-stage.sh || exit $?;

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} with Init" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h almalinux${ALMALINUX_VER}-init --privileged" \
 org.ugoole.docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGRTMIN+3

## Volume
#VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init" ]


# AlmaLinux with init (onbuild)
FROM init AS init-onbuild

# AlmaLinux Version
ARG ALMALINUX_VER

# Set Workdir
WORKDIR /.onbuild

# Copy onbuild scripts to Workdir
COPY 020_build-stage_alma.sh ./onbuild-stage.sh
COPY \[1-9\]\[0-9\]\[0-9\]_*.sh ./

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} with Init (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 docker.run.options="-d -P -h almalinux${ALMALINUX_VER}-init --privileged" \
 org.ugoole.docker.run.confirm-startup=""

# ONBUILD: Parameters for localization
ONBUILD \
ARG \
 LANGUAGE \
 TIMEZONE \
 KEYBOARD \
 KBDTABLE

# Enable logrotate / SUDO / Sshd
ONBUILD \
ARG \
 LOGROTATION \
 ENABLE_SUDO \
 ENABLE_SSHD

# ONBUILD: RPM Packages and Shell Scripts for ONBUILD
ONBUILD \
ARG \
 ONBUILD_RPM_PACKAGES \
 ONBUILD_SHELL_SCRIPT

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /.onbuild

# ONBUILD: COPY contents to workdir
ONBUILD \
COPY * ./

# ONBUILD: SetUp
ONBUILD \
RUN \
 --mount=type=secret,id=ROOTPSWD \
 --mount=type=secret,id=DOCKER_USERS \
 set -ux -o errtrace -o functrace -o pipefail; . ./onbuild-stage.sh || exit $?;

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

