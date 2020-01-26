#
# centos:centos6-upstart
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos:centos6-upstart"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos6-minimal AS build-stage

# Labels
LABEL \
 build-stage="true"

# Shell
SHELL \
 [ "/bin/bash", "-u", "-x", "-c" ]

# Set Workdir
WORKDIR \
 /root

# Env
ENV \
 container=docker

# SetUp
RUN \
 : "Modify yum-fastestmirror" && { \
  yum_fastmirror_conf="/etc/yum/pluginconf.d/fastestmirror.conf"; \
  [ -e "${yum_fastmirror_conf}" ] && \
  sed -ri 's/^verbose=0$/verbose=1/g' "${yum_fastmirror_conf}" && \
  sed -ri 's/^(#*)include_only=.*$/include_only=.jp,.org/g' "${yum_fastmirror_conf}" && \
  sed -ri '/^include_only=.*$/a prefer=www.ftp.ne.jp' "${yum_fastmirror_conf}" && \
  cat "${yum_fastmirror_conf}"; \
 } && \
 : "Install EPEL" && { \
  yum -v -y install epel-release; \
 } && \
 : "Install packages" && { \
  yum -v -y update && \
  yum -v -y install initscripts MAKEDEV sudo && \
  yum -v -y clean all; rm -rf /var/cache/yum/*; \
 } && \
 : "Rebuild RPM DB" && { \
  rpm -e --nodeps kernel kernel-firmware redhat-logos; \
  rpm --rebuilddb; \
 } && \
 : "Disable services" && { \
  for service in iptables netfs udev-post; \
  do chkconfig "$service" off; done; \
 } && \
 : "Change upstart's scripts" && { \
  sed -ri 's/^/#/g' /etc/init/tty.conf && \
  sed -ri 's/wn -r now/wn -h now/g' /etc/init/control-alt-delete.conf || :; \
 } && \
 : "Cleanup" && { \
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done || :; \
  yum -v -y clean all; rm -rf /var/cache/yum/*; \
  rm -rf /root/*; \
 } 2>/dev/null || :; \
 echo;

# Reset Workdir
WORKDIR \
 /

# CentOS 6 with upstart
FROM scratch AS centos6-upstart-stage

# Labels
LABEL \
 name="CentOS 6 with Upstart" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license=""

# Labels for build
LABEL \
 build-date="" \
 docker.build.options=""

# Set Workdir
WORKDIR \
 /root

# COPY from build-stage
COPY \
 --from=build-stage / /

# Reset Workdir
WORKDIR \
 /

# ONBUILD: Set Workdir
ONBUILD \
ARG \
 DOCKER_BUILD_DIR=docker-build
ONBUILD \
WORKDIR \
 /root/${DOCKER_BUILD_DIR}

# ONBUILD: System locale
ONBUILD \
ARG \
 CONTAINER_LANGUAGE="en_US.UTF-8"

# ONBUILD: keymap and timezone
ONBUILD \
ARG \
 CONTAINER_KEYBOARD="jp106"
ONBUILD \
ARG \
 CONTAINER_KBLAYOUT="jp"

# ONBUILD: timezone
ONBUILD \
ARG \
 CONTAINER_TIMEZONE="Asia/Tokyo"

# ONBUILD: root password
ONBUILD \
ARG \
 CONTAINER_ROOTPSWD=""

# Default login
ONBUILD \
ARG \
 DOCKER_UID=500
ONBUILD \
ARG \
 DOCKERUSER=dockeruser
ONBUILD \
ARG \
 DOCKERPASS=""

# ONBUILD: sshd
ONBUILD \
ARG \
 without_ssh=""

# ONBUILD: logging
ONBUILD \
ARG \
 without_logging=""

# ONBUILD: cron
ONBUILD \
ARG \
 without_cron=""

# ONBUILD: Additional Packages
ONBUILD \
ARG \
 packages=""

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux ; \
 language="${CONTAINER_LANGUAGE:-en_US.UTF-8}"; \
 keyboard="${CONTAINER_KEYBOARD:-jp106}"; \
 kblayout="${CONTAINER_KBLAYOUT:-jp}"; \
 timezone="${CONTAINER_TIMEZONE:-Asia/Tokyo}"; \
 rootpswd="${CONTAINER_ROOTPSWD:-}"; \
 : "ONBUILD: SetUp system locale: ${language}" && { \
  lc_cntr=$(echo "${language}"|cut -d. -f1); lc_cntr="${lc_cntr:-en_US}"; \
  lc_lang=$(echo "${language}"|cut -d. -f2); lc_lang="${lc_lang:-UTF-8}"; \
  localedef -v -c -i "${lc_cntr}" -f "${lc_lang}" "${lc_cntr}.${lc_lang}"; \
  echo "LANG=${locale:-en_US.UTF-8}" 1>/etc/sysconfig/i18n; \
 }; \
 : "ONBUILD: keymap: keyboard=${keyboard} layout=${kblayout}" && { \
  syscfgkb="/etc/sysconfig/keyboard"; \
  { [ -e "${syscfgkb}" ] || touch "${syscfgkb}" || :; } && \
  . "${syscfgkb}" && { \
   if [ -z "${KEYTABLE:-}" ]; \
   then echo 'KEYTABLE="'"${keyboard}"'"' 1>>"${syscfgkb}" && \. "${syscfgkb}"; \
   elif [ "${KEYTABLE:-}" = "${keyboard}" ]; \
   then sed -ri 's/^(KEYTABLE)=.*$/\1="'"${keyboard}"'"/g' "${syscfgkb}"; \
   fi; \
   if [ -z "${MODEL:-}" ]; \
   then echo 'MODEL="'"${keyboard}"'"' 1>>"${syscfgkb}" && . "${syscfgkb}"; \
   elif [ "${MODEL:-}" = "${keyboard}" ]; \
   then sed -ri 's/^(MODEL)=.*$/\1="'"${keyboard}"'"/g' "${syscfgkb}"; \
   fi; \
   if [ -z "${LAYOUT:-}" ]; \
   then echo 'LAYOUT="'"${kblayout}"'"' 1>>"${syscfgkb}" && . "${syscfgkb}"; \
   elif [ "${LAYOUT:-}" = "${kblayout}" ]; \
   then sed -ri 's/^LAYOUT=.*$/LAYOUT="'"${kblayout}"'"/g' "${syscfgkb}"; \
   fi; \
  }; \
 }; \
 : "ONBUILD: timezone: timezone=${timezone}" && { \
  if [ -e "/etc/sysconfig/clock" ]; \
  then echo 'ZONE="'"${timezone:-Asia/Tokyo}"'"' >/etc/sysconfig/clock; \
  fi; \
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
 : "ONBUILD: SetUp default user" && { \
  if [ -n "${DOCKERUSER:-}" ]; \
  then \
   docker_uid="${DOCKER_UID:-500}"; \
   dockeruser="${DOCKERUSER:-dockeruser}"; \
   dockerpass="${DOCKERPASS}"; \
   groupadd -g "${docker_uid}" "${dockeruser}" && \
   useradd -u "${docker_uid}" -g "${dockeruser}" -m "${dockeruser}" && \
   if [ -n "${dockerpass:-}" ]; \
   then echo "${dockeruser}:${dockerpass}"; \
   else echo "${dockeruser}:$(dd if=/dev/urandom count=50 2>/dev/null|md5sum)"; \
   fi |chpasswd; \
   sudoers="/etc/sudoers"; \
   newline="# For docker user\n${dockeruser}\tALL=(ALL)\tNOPASSWD: ALL"; \
   sed -ri '/^root[ \t]*ALL.*$/a '"${newline}" "${sudoers}"; \
  fi; \
 }; \
 if [ -n "${without_ssh:-}${without_logrotate:-}${packages:-}" ]; \
 then yum -v -y update; \
 fi; \
 if [ -n "${without_ssh:-}" ]; \
 then echo "Without SSHd, skipping this instruction."; \
 else \
  : "ONBUILD: sshd: Install openssh-server" && { \
   yum -v -y install openssh-server; \
  } && \
  : "ONBUILD: sshd: Change sshd's settings" && { \
   sshd_config="/etc/ssh/sshd_config"; \
   sed -ri 's/^#PermitRootLogin[ ]*yes/PermitRootLogin yes/' "${sshd_config}" && \
   sed -ri 's/^UsePAM yes/UsePAM no/' "${sshd_config}" && \
   cat /etc/ssh/sshd_config; \
  } && \
  : "ONBUILD: sshd: Enable sshd service" && { \
   /sbin/chkconfig --add sshd || :; \
   /sbin/chkconfig --levels 2345 sshd on || :; \
  }; \
 fi; \
 if [ -n "${without_logging:-}" ]; \
 then echo "Without logging, skipping this instruction."; \
 else \
  : "ONBUILD: logging: install rsyslog and logrotate" && { \
   yum -v -y install rsyslog logrotate; \
  }; \
 fi; \
 if [ -n "${without_cron:-}" ]; \
 then echo "Without cron, skipping this instruction."; \
 else \
  : "ONBUILD: cron: install cron" && { \
   yum -v -y install cronie; \
  }; \
 fi; \
 if [ -z "${packages:-}" ]; \
 then echo "No packages, skipping this instruction."; \
 else \
  : "ONBUILD: PKG: install packages are: ${packages}" && { \
   yum -v -y install ${packages}; \
  }; \
 fi; \
 : "ONBUILD: Cleanup" && { \
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done; \
  yum -v -y clean all; rm -rf /var/cache/yum/*; \
  cd; rm -rf /root/*; \
 } 2>/dev/null || :; \
 echo;

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR \
 /

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos6-upstart --privileged" \
 docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

## Publish a container's port(s) to the host
#EXPOSE 22

# Start /sbin/init
CMD [ "/sbin/init", "3" ]

