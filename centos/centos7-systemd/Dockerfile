#
# centos:centos7-systemd
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos:centos7-systemd"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 license=""

# Labels for build
LABEL \
 build-date="" \
 docker.build.options=""

# Env
ENV \
 container=docker

# Modify yum-fastestmirror
RUN \
 set -x; \
 yum_fastmirror_conf="/etc/yum/pluginconf.d/fastestmirror.conf"; \
 sed -ri 's/^verbose=0$/verbose=1/g' "${yum_fastmirror_conf}" && \
 sed -ri 's/^(#*)include_only=.*$/include_only=.jp,.org/g' "${yum_fastmirror_conf}" && \
 sed -ri '/^include_only=.*$/a prefer=www.ftp.ne.jp' "${yum_fastmirror_conf}" && \
 cat "${yum_fastmirror_conf}"

# Install epel
RUN \
 set -x; \
 yum -v -y install epel-release

# Install packages
RUN \
 set -x; \
 yum -v -y update && \
 yum -v -y install systemd-sysv which make openssh-server sudo && \
 yum -v -y clean all

# Delete systemd files
RUN \
 set -x; \
 rm -f /etc/systemd/system/*.wants/*; \
 cd /usr/lib/systemd/system && { \
  for item in \
  ./multi-user.target.wants/dbus.service \
  ./multi-user.target.wants/getty.target \
  ./multi-user.target.wants/systemd-ask-password-wall.path \
  ./multi-user.target.wants/systemd-update-utmp-runlevel.service \
  ./sockets.target.wants/dbus.socket \
  ./sockets.target.wants/systemd-initctl.socket \
  ./sockets.target.wants/systemd-udevd-control.socket \
  ./sockets.target.wants/systemd-udevd-kernel.socket \
  ./sysinit.target.wants/systemd-ask-password-console.path \
  ./sysinit.target.wants/systemd-udevd.service \
  ./sysinit.target.wants/systemd-udev-trigger.service \
  ./sysinit.target.wants/systemd-vconsole-setup.service \
  ./local-fs.target.wants/systemd-remount-fs.service ; \
  do \
   rm -f "$item"; \
  done 1>/dev/null 2>&1; \
 }; \
 cd /usr/lib/systemd/system/sysinit.target.wants && { \
  for item in *; \
  do \
   echo "$item"|grep -E '^systemd-tmpfiles-setup.*service' || \
   rm -f "$item"; \
  done 1>/dev/null 2>&1; \
 };

# Change root passwor
ARG \
 ROOTPASSWD=root
RUN \
 set -x; \
 echo "root:${ROOTPASSWD:-root}" |chpasswd

# Create default user
ARG \
 DOCKERUSER=dockeruser
ARG \
 DOCKERPASS=dockeruser
RUN \
 set -x; \
 dockeruser="${DOCKERUSER:-dockeruser}"; \
 dockerpass="${DOCKERPASS:-dockeruser}"; \
 groupadd -g 500 "${dockeruser}" && \
 useradd -u 500 -g "${dockeruser}" -m "${dockeruser}" && \
 echo "${dockeruser}:${dockerpass}" |chpasswd

# keymap
ARG \
 keyboard=jp106
RUN \
 set -x; \
 . /etc/vconsole.conf && \ 
 [ "$KEYMAP" = "$keymap" ] || { \
  sed -ri 's/^KEYMAP=.*$/KEYMAP="'$keyboard'"/g' /etc/vconsole.conf; \
 };

# timezone
ARG \
 timezone=Asia/Tokyo
RUN \
 set -x; \
 [ ! -e "/usr/share/zoneinfo/${timezone}" ] || { \
  cp -pf /etc/localtime{,.ORIG} && \
  ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime; \
 }; \
 ls -l /etc/localtime

# SUDOers
RUN \
 set -x; \
 sudoers="/etc/sudoers"; \
 newline="# For docker user\n${DOCKERUSER:-dockeruser}\tALL=(ALL)\tNOPASSWD: ALL"; \
 sed -ri '/^root[ \t]*ALL.*$/a '"${newline}" "${sudoers}"

# Change sshd's settings
RUN \
 set -x; \
 sshd_config="/etc/ssh/sshd_config"; \
 sed -ri 's/^#PermitRootLogin[ ]*yes/PermitRootLogin yes/' "${sshd_config}" && \
 sed -ri 's/^UsePAM yes/UsePAM no/' "${sshd_config}" && \
 cat /etc/ssh/sshd_config

# sshd
RUN \
 set -x; \
 systemctl enable sshd.service;

# Cleanup
RUN \
 set -x; \
 for log in $(find /var/log -type f 2>/dev/null); \
 do [ -f "$log" ] && cat /dev/null 1>"$log"; done 2>/dev/null || :; \
 for log in {,/root,/tmp,/var/tmp}/*.log; \
 do rm -f "$log"; done 2>/dev/null || :; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
 rm -rf "${WORKDIR}"; } || :

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos7-systemd --privileged" \
 docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

# Volume
VOLUME [ "/sys/fs/cgroup" ]

# Publish a container's port(s) to the host
EXPOSE 22

# Start /sbin/init
CMD [ "/sbin/init" ]

