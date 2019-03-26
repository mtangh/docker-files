#
# centos:centos6-minimal
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos:centos6-minimal"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos6 AS build-stage

# BUILDER:
# CentOS Image Root
ENV \
 CENTOS_ROOT=/centos-image/rootfs

# BUILDER:
# RPM GPG Key
ENV \
 RPM_GPG_KEY=/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# BUILDER:
# Shell
SHELL \
 [ "/bin/bash", "-x", "-c" ]

# BUILDER:
# Set Workdir
WORKDIR \
 /root

# BUILDER:
# COPY setup.sh
COPY \
 setup.sh /root/setup.sh

# BUILDER:
# - Create a folder for our new root structure
# - Initialize RPM database
# - Download and install the centos-release package
# - Install yum without docs and install only the
#   english language files during the process
# - Configure yum to avoid installing of docs and
#   other language files than english generally
# - Chroot to the environment and install some additional tools
RUN \
 mkdir -p "${CENTOS_ROOT}" && \
 rpm --root "${CENTOS_ROOT}" --initdb && \
 yum -v -y reinstall --downloadonly --downloaddir . centos-release && \
 rpm --root "${CENTOS_ROOT}" --nodeps -ivh centos-release*.rpm && \
 rpm --root "${CENTOS_ROOT}" --import "${CENTOS_ROOT}${RPM_GPG_KEY}" && \
 yum -v -y \
  --installroot=${CENTOS_ROOT} \
  --setopt=override_install_langs=en_US.utf8 \
  --setopt=tsflags='nodocs' \
  install yum && \
 sed -ri \
  "/distroverpkg=centos-release/a override_install_langs=en_US.utf8\ntsflags=nodocs" \
  "${CENTOS_ROOT}/etc/yum.conf" && \
 : "Chroot to the environment and install some additional tools." && { \
  cp -f /etc/resolv.conf ${CENTOS_ROOT}/etc/resolv.conf && \
  chroot "${CENTOS_ROOT}" /bin/bash <./setup.sh && \
  rm -f ${CENTOS_ROOT}/etc/resolv.conf; \
 } && \
 echo;

# CentOS6 from Scratch
FROM scratch AS centos6-minimal-stage

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="CentOS6 from Scratch" \
 vendor="UGOOLE.ORG" \
 license=""

# Labels for build
LABEL \
 build-date="" \
 docker.build.options=""

# Env
ENV \
 container=docker

# COPY From build-stage
COPY \
 --from=build-stage /centos-image/rootfs/ /

