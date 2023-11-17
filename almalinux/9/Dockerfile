#
# almalinux9:*
#
#@  DOCKER_IMAGEPATH="almalinux9"
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

# AlmaLinux Version
ARG ALMALINUX_VER="9"

# AlmaLinux rootfs Image Dir
ARG ALMALINUXROOT="/almalinux-image/ROOT"

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


# AlmaLinux rootfs
FROM almalinux:${ALMALINUX_VER} AS rootfs

# AlmaLinux Version
ARG ALMALINUX_VER

# AlmaLinux rootfs Image
ARG ALMALINUXROOT

# Build env
ENV \
 ALMALINUX_VER="${ALMALINUX_VER:-}" \
 ALMALINUXROOT="${ALMALINUXROOT:-}"

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY shell scripts to Workdir
COPY "000_build-chrootdir_AL${ALMALINUX_VER}.sh" ./build-chrootdir.sh

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
 name="AlmaLinux ${ALMALINUX_VER} rootfs" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 build-stage="true"


# AlmaLinux minimal
FROM scratch AS minimal

# Env
ENV container="docker"

# AlmaLinux Version
ARG ALMALINUX_VER

# AlmaLinux rootfs Image
ARG ALMALINUXROOT

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
COPY --from=rootfs "${ALMALINUXROOT}"/ /

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY shell scripts to Workdir
COPY 010_build-stage.sh ./build-stage.sh
COPY \[12\]\[0-9\]\[0-9\]_*.sh ./

# SetUp
RUN \
 set -ux; . ./build-stage.sh || exit 1;

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} Minimal" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="" \
 docker.run.confirm-startup=""


# AlmaLinux with systemd
FROM scratch AS systemd

# Env
ENV container="docker"

# AlmaLinux Version
ARG ALMALINUX_VER

# COPY From minimal image
COPY --from=minimal / /

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY shell scripts to Workdir
COPY 010_build-stage.sh ./build-stage.sh
COPY \[13\]\[0-9\]\[0-9\]_*.sh ./

# SetUp
RUN \
 set -ux; . ./build-stage.sh || exit 1;

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h almalinux${ALMALINUX_VER}-systemd --privileged" \
 docker.run.confirm-startup=""

# STOP SIGNAL
#STOPSIGNAL SIGINT
STOPSIGNAL SIGRTMIN+3

## Volume
#VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init" ]


# AlmaLinux minimal (onbuild)
FROM minimal AS minimal-onbuild

# AlmaLinux Version
ARG ALMALINUX_VER

# Set Workdir
WORKDIR /.onbuild

# Copy onbuild scripts to Workdir
COPY 010_build-stage.sh ./onbuild.sh
COPY \[19\]\[0-9\]\[0-9\]_*.sh ./

# AlmaLinux Version
RUN \
 set -ux; \
 echo "${ALMALINUX_VER}" >./ALMALINUX_VER;

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} Minimal (onbuild)" \
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
 : "ONBUILD: Run" && { \
  scrptdir="/.onbuild"; \
  . ${scrptdir}/onbuild.sh || exit 1; \
  rm -rf "${scrptdir}/" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /


# AlmaLinux with systemd (onbuild)
FROM systemd AS systemd-onbuild

# AlmaLinux Version
ARG ALMALINUX_VER

# Set Workdir
WORKDIR /.onbuild

# Copy onbuild scripts to Workdir
COPY 010_build-stage.sh ./onbuild.sh
COPY \[1-9\]\[0-9\]\[0-9\]_*.sh ./

# AlmaLinux Version
RUN \
 set -ux; \
 echo "${ALMALINUX_VER}" >./ALMALINUX_VER;

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="AlmaLinux ${ALMALINUX_VER} with Systemd (onbuild)" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h almalinux${ALMALINUX_VER}-systemd --privileged" \
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
 : "ONBUILD: Run" && { \
  scrptdir="/.onbuild"; \
  . ${scrptdir}/onbuild.sh || exit 1; \
  rm -rf "${scrptdir}/" || :; \
 } && \
 : "ONBUILD: Done.";

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR /

