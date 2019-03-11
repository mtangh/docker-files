#
# centos:centos6-upstart
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos:centos6-upstart"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos6

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="CentOS 6 with Upstart" \
 vendor="UGOOLE.ORG" \
 license=""

# Labels for build
LABEL \
 build-date="" \
 docker.build.options=""

# Env
ENV \
 container=docker

# root password
ARG \
 ROOTPASSWD=root

# Default login
ARG \
 DOCKER_UID=500
ARG \
 DOCKERUSER=dockeruser
ARG \
 DOCKERPASS=dockeruser

# SetUp
RUN \
 set -x; \
 : "Modify yum-fastestmirror" && { \
  yum_fastmirror_conf="/etc/yum/pluginconf.d/fastestmirror.conf"; \
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
  { rm -rf /var/cache/yum/* && yum -v -y clean all; }; \
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
 : "Reset root password" && { \
  echo "root:${ROOTPASSWD:-root}" |chpasswd; \
 }; \
 : "SetUp default user" && { \
  docker_uid="${DOCKER_UID:-500}"; \
  dockeruser="${DOCKERUSER:-dockeruser}"; \
  dockerpass="${DOCKERPASS:-dockeruser}"; \
  groupadd -g "${docker_uid}" "${dockeruser}" && \
  useradd -u "${docker_uid}" -g "${dockeruser}" -m "${dockeruser}" && \
  echo "${dockeruser}:${dockerpass}" |chpasswd; \
 }; \
 : "SetUp sudoers" && { \
  sudoers="/etc/sudoers"; \
  newline="# For docker user\n${dockeruser}\tALL=(ALL)\tNOPASSWD: ALL"; \
  sed -ri '/^root[ \t]*ALL.*$/a '"${newline}" "${sudoers}"; \
 }; \
 : "Cleanup" && { \
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done || :; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done || :; \
 } 2>/dev/null || :; \
 echo;

#  ONBUILD: Keyboard and timezone
ONBUILD \
ARG \
 keyboard=jp106
ONBUILD \
ARG \
 keylayout=jp
ONBUILD \
ARG \
 timezone=Asia/Tokyo

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
 if [ -n "${without_ssh}" -o -a "${without_logrotate}" -o -a "${packages}" ]; \
 then yum -v -y update; fi; \
 if [ "${without_ssh}" = "yes" ]; \
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
 if [ "${without_logrotate}" = "yes" ]; \
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
  { rm -rf /var/cache/yum/* && yum -v -y clean all; }; \
 } 2>/dev/null || :; \
 echo;

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

