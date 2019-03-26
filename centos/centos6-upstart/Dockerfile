#
# centos:centos6-upstart
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos:centos6-upstart"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos6 AS build-stage

# Labels
LABEL \
 build-stage="true"

# Shell
SHELL \
 [ "/bin/bash", "-x", "-c" ]

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

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="CentOS 6 with Upstart" \
 vendor="UGOOLE.ORG" \
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
WORKDIR \
 /root

# ONBUILD: System locale
ONBUILD \
ARG \
 localedef="en_US.UTF-8"

#  ONBUILD: Keyboard and timezone
ONBUILD \
ARG \
 keyboard="jp106"
ONBUILD \
ARG \
 keylayout="jp"
ONBUILD \
ARG \
 timezone="Asia/Tokyo"

# root password
ONBUILD \
ARG \
 ROOTPASSWD=""

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

# ONBUILD: logrotate
ONBUILD \
ARG \
 without_logrotate=""

# ONBUILD: Additional Packages
ONBUILD \
ARG \
 packages=""

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -x; \
 : "ONBUILD: SetUp system locale: $localedef" && { \
  lc_cn=$(echo "${localedef}"|cut -d. -f1 2>/dev/null); \
  lc_lang=$(echo "${localedef}"|cut -d. -f2 2>/dev/null); \
  [ "${lc_cn:-en_US}" == "en_US" -a "${lc_lang:-UTF-8}" == "UTF-8" ] || { \
   localedef -v -c -i "${lc_cn:-en_US}" -f "${lc_lang:-UTF-8}" "${lc_cn:-en_US}.${lc_lang:-UTF-8}"; \
  }; \
 }; \
 : "ONBUILD: keyboard=$keyboard keylayout=$keylayout" && { \
  syscfg_keyboard="/etc/sysconfig/keyboard"; \
  . "${syscfg_keyboard}" && { \
   [ "$KEYTABLE" = "$keyboard" ] || { \
    sed -ri 's/^(KEYTABLE|MODEL)=.*$/\1="'$keyboard'"/g' "${syscfg_keyboard}"; \
   }; \
   [ "$LAYOUT" = "$keylayout" ] || { \
    sed -ri 's/^LAYOUT=.*$/LAYOUT="'$keylayout'"/g' "${syscfg_keyboard}"; \
   }; \
  }; \
 } && \
 : "ONBUILD: timezone=$timezone" && { \
  [ ! -e "/etc/sysconfig/clock" ] || { \
   echo 'ZONE="'$timezone'"' >/etc/sysconfig/clock; \
  }; \
  [ ! -e "/usr/share/zoneinfo/${timezone}" ] || { \
   cp -pf /etc/localtime{,.ORIG} && \
   ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime; \
  }; \
  ls -l /etc/localtime; \
 }; \
 : "ONBUILD: Set root password" && { \
  [ -z "${ROOTPASSWD}" ] || { \
   echo "root:${ROOTPASSWD}" |chpasswd; }; \
 }; \
 : "ONBUILD: SetUp default user" && { \
  if [ -n "${DOCKERUSER}" ]; \
  then \
   docker_uid="${DOCKER_UID:-500}"; \
   dockeruser="${DOCKERUSER:-dockeruser}"; \
   dockerpass="${DOCKERPASS}"; \
   groupadd -g "${docker_uid}" "${dockeruser}" && \
   useradd -u "${docker_uid}" -g "${dockeruser}" -m "${dockeruser}" && \
   if [ -n "${DOCKERPASS}" ]; \
   then echo "${dockeruser}:${dockerpass}"; \
   else echo "${dockeruser}:$(dd if=/dev/urandom count=50 2>/dev/null|md5sum)"; \
   fi |chpasswd; \
   sudoers="/etc/sudoers"; \
   newline="# For docker user\n${dockeruser}\tALL=(ALL)\tNOPASSWD: ALL"; \
   sed -ri '/^root[ \t]*ALL.*$/a '"${newline}" "${sudoers}"; \
  fi; \
 }; \
 if [ -n "${without_ssh}" \
   -o -n "${without_logrotate}" \
   -o -n "${packages}" ]; \
 then yum -v -y update; \
 fi; \
 if [ -n "${without_ssh}" ]; \
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
 if [ -n "${without_logrotate}" ]; \
 then echo "Without logrotate, skipping this instruction."; \
 else \
  : "ONBUILD: logrotate: install logrotate" && { \
   yum -v -y install logrotate; \
  }; \
 fi; \
 if [ -z "${packages}" ]; \
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
  rm -rf /root/*; \
 } 2>/dev/null || :; \
 echo;

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR \
 /

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos6-upstart" \
 docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

## Publish a container's port(s) to the host
#EXPOSE 22

# Start /sbin/init
CMD [ "/sbin/init", "3" ]

