#
# centos:centos7-from-scratch
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos:centos7-from-scratch"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7 AS builder

# CentOS Image Root
ENV \
 CENTOS_ROOT=/centos-image/rootfs

ENV \
 RPM_GPG_KEY=/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

# BUILDER:
# Shell
SHELL \
 ["/bin/bash", "-x", "-c"]

# BUILDER:
# Set Workdir
WORKDIR \
 /root

# BUILDER:
# Create a folder for our new root structure
RUN \
 mkdir -p "${CENTOS_ROOT}" && \
 echo;

# BUILDER:
# Initialize RPM database
RUN \
 rpm --root "${CENTOS_ROOT}" --initdb && \
 echo;
 
# BUILDER:
# Download and install the centos-release package
RUN \
 yum -v -y reinstall --downloadonly --downloaddir . centos-release && \
 rpm --root "${CENTOS_ROOT}" --nodeps -ivh centos-release*.rpm && \
 rpm --root "${CENTOS_ROOT}" --import "${CENTOS_ROOT}${RPM_GPG_KEY}" && \
 echo;

# BUILDER:
# Install yum without docs and install only the
# english language files during the process
RUN \
 yum -v -y \
  --installroot=${CENTOS_ROOT} \
  --setopt=override_install_langs=en_US.utf8 \
  --setopt=tsflags='nodocs' \
  install yum && \
 echo;
 
# BUILDER:
# Configure yum to avoid installing of docs and
# other language files than english generally
RUN \
 sed -ri \
  "/distroverpkg=centos-release/a override_install_langs=en_US.utf8\ntsflags=nodocs" \
  "${CENTOS_ROOT}/etc/yum.conf" && \
 echo;

# BUILDER:
# Chroot to the environment and install some additional tools
RUN \
 : && { \
  echo '#!/bin/bash -x'; \
  echo 'cat <<_EOF_ >/etc/reaolv.conf || exit 1'; \
  cat /etc/resolv.conf; \
  echo '_EOF_'; \
  echo 'yum -v -y install procps-ng iputils || exit 2'; \
  echo ': "Cleanup" && {'; \
  echo ' for log in $(find /var/log -type f)'; \
  echo ' do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :'; \
  echo ' for log in {,/root,/tmp,/var/tmp}/*.log'; \
  echo ' do rm -f "$log"; done || :'; \
  echo ' yum -v -y clean all'; \
  echo ' rm -rf /var/cache/yum/*'; \
  echo ' rm -rf /root/*'; \
  echo '} 2>/dev/null || :'; \
  echo 'rm -f /etc/resolv.conf'; \
  echo 'exit 0'; \
 } 1>./setup.sh; \
 chroot "${CENTOS_ROOT}" /bin/bash <./setup.sh && \
 echo;

# BUILDER:
# Cleanup
RUN \
 echo;

# CentOS7 from Scratch
FROM scratch

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="CentOS7 from Scratch" \
 vendor="UGOOLE.ORG" \
 license=""

# Labels for build
LABEL \
 build-date="" \
 docker.build.options=""

# Env
ENV \
 container=docker

COPY \
 --from=builder /centos-image/rootfs/ /

