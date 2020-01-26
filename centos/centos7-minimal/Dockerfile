#
# centos:centos7-minimal
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos:centos7-minimal"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7 AS build-stage

# BUILDER:
# Shell
SHELL \
 [ "/bin/bash", "-u", "-x", "-c" ]

# BUILDER:
# CentOS Image Root
ENV \
 CENTOS_ROOT=/centos-image/rootfs

# BUILDER:
# RPM GPG Key
ENV \
 RPM_GPG_KEY=/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

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
 echo "CENTOS_ROOT=${CENTOS_ROOT:=/centos-image/rootfs}"; \
 echo "RPM_GPG_KEY=${RPM_GPG_KEY:=/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7}"; \
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
  cp -f "/etc/resolv.conf" "${CENTOS_ROOT}/etc/resolv.conf" && \
  chroot "${CENTOS_ROOT}" /bin/bash <./setup.sh && \
  rm -f "${CENTOS_ROOT}/etc/resolv.conf"; \
 } && \
 echo;

# CentOS7 from Scratch
FROM scratch AS centos7-minimal-stage

# Labels
LABEL \
 name="CentOS7 Minimal" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
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

# ONBUILD: System locale
ONBUILD \
ARG \
 CONTAINER_LANGUAGE="en_US.UTF-8"

# ONBUILD: keymap and timezone
ONBUILD \
ARG \
 CONTAINER_KEYBOARD="jp106"

# ONBUILD: timezone
ONBUILD \
ARG \
 CONTAINER_TIMEZONE="Asia/Tokyo"

# ONBUILD: root password
ONBUILD \
ARG \
 CONTAINER_ROOTPSWD=""

# ONBUILD: Set Workdir
ONBUILD \
ARG \
 BUILDDIR=/root/docker-container-build
ONBUILD \
WORKDIR \
 ${BUILDDIR}

# ONBUILD: Build script
ONBUILD \
COPY \
 onbuild.* ${BUILDDIR}/

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux ; \
 : "ONBUILD: Init" && { \
  language="${CONTAINER_LANGUAGE:-en_US.UTF-8}"; \
  keyboard="${CONTAINER_KEYBOARD:-jp106}"; \
  timezone="${CONTAINER_TIMEZONE:-Asia/Tokyo}"; \
  rootpswd="${CONTAINER_ROOTPSWD:-}"; \
  if [ -e "./onbuild.rc" ]; \
  then . "./onbuild.rc" || exit 1; \
  fi || :; \
 }; \
 : "ONBUILD: SetUp system locale: ${language}" && { \
  lc_cntr=$(echo "${language}"|cut -d. -f1); lc_cntr="${lc_cntr:-en_US}"; \
  lc_lang=$(echo "${language}"|cut -d. -f2); lc_lang="${lc_lang:-UTF-8}"; \
  localedef -v -c -i "${lc_cntr}" -f "${lc_lang}" "${lc_cntr}.${lc_lang}"; \
  localectl set-locale "LANG=${lc_cntr}.${lc_lang}" || \
  echo "LANG=${lc_cntr}.${lc_lang}" 1>/etc/locale.conf; \
 }; \
 : "ONBUILD: keymap: keyboard=${keyboard}" && { \
  if [ -e "/etc/vconsole.conf" ]; \
  then . /etc/vconsole.conf; fi; \
  if [ -z "${KEYMAP:-}" ]; \
  then echo 'KEYMAP='"${keyboard}" 1>>/etc/vconsole.conf && . /etc/vconsole.conf; fi; \
  if [ "${KEYMAP:-}" != "${keyboard}" ]; \
  then sed -ri 's/^KEYMAP=.*$/KEYMAP="'"${keyboard}"'"/g' /etc/vconsole.conf; fi; \
 }; \
 : "ONBUILD: timezone: timezone=${timezone}" && { \
  if [ -e "/usr/share/zoneinfo/${timezone}" ]; \
  then \
   { [ -e "/etc/localtime" ] && mv -f /etc/localtime{,.ORIG} || :; } && \
   ln -sf "/usr/share/zoneinfo/${timezone}" /etc/localtime; \
  fi; \
  ls -l /etc/localtime; \
 }; \
 : "ONBUILD: Set root password" && { \
  if [ -n "${rootpswd:-}" ]; \
  then echo "${rootpswd}" |passwd --stdin root; passwd -l root; \
  fi; \
 }; \
 if [ -s "./onbuild.sh" ]; \
 then echo "Not found 'onbuild.sh', skipping this instruction."; \
 else \
  : "ONBUILD: BUILD-SCRIPTS: Execute './onbuild.sh'" && { \
   bash -ux "./onbuild.sh" || exit 1; \
  }; \
 fi; \
 : "ONBUILD: Cleanup" && { \
  cd && { ; \
   for log in $(find /var/log -type f); \
   do [ -f "$log" ] && cat /dev/null 1>"$log"; done; \
   for log in {,/var}/tmp/*.log; do rm -f "$log"; done; \
   yum -v -y clean all; rm -rf /var/cache/yum/*; \
   [ -d "${BUILDDIR:--}" ] && rm -rf "${BUILDDIR}" || :; \
   rm -rf /root/*; \
  }; \
 } || :; \
 echo;

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR \
 /

