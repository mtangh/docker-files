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
 yum -v -y install initscripts MAKEDEV openssh-server sudo && \
 yum -v -y clean all
RUN \
 set -x; \
 rpm -e --nodeps kernel kernel-firmware redhat-logos; \
 rpm --rebuilddb

# Disable services
RUN \
 set -x; \
 for service in iptables netfs udev-post; \
 do \
  chkconfig "$service" off; \
 done;

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

# Keyboard
ARG \
 keyboard=jp106
ARG \
 keylayout=jp
RUN \
 set -x; \
 . /etc/sysconfig/keyboard; \
 [ "$KEYTABLE" = "$keyboard" ] || { \
  sed -ri 's/^(KEYTABLE|MODEL)=.*$/\1="'$keyboard'"/g' /etc/sysconfig/keyboard; \
 }; \
 [ "$LAYOUT" = "$keylayout" ] || { \
  sed -ri 's/^LAYOUT=.*$/LAYOUT="'$keylayout'"/g' /etc/sysconfig/keyboard; \
 };

# timezone
ARG \
 timezone=Asia/Tokyo
RUN \
 set -x; \
 [ ! -e "/etc/sysconfig/clock" ] || { \
  echo 'ZONE="'$timezone'"' >/etc/sysconfig/clock; \
 }; \
 [ ! -e "/usr/share/zoneinfo/${timezone}" ] || { \
  cp -pf /etc/localtime{,.ORIG} && \
  ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime; \
 }; \
 ls -l /etc/localtime

# Change upstart's scripts
RUN \
 set -x; \
 sed -ri 's/^/#/g' /etc/init/tty.conf && \
 sed -ri 's/wn -r now/wn -h now/g' /etc/init/control-alt-delete.conf

# SUDOers
RUN \
 set -x; \
 sudoers="/etc/sudoers"; \
 newline="# For docker user\n${DOCKERUSER:-dockeruser}\tALL=(ALL)\tALL"; \
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
 /sbin/chkconfig --add sshd 1>/dev/null 2>&1 || : ; \
 /sbin/chkconfig --levels 2345 sshd on 1>/dev/null 2>&1 || : ;

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in {,/root,/tmp}/*.log; do rm -f "$log"; done; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && rm -rf "${WORKDIR}" || :

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos6-upstart" \
 docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

# Publish a container's port(s) to the host
EXPOSE 22

# Start /sbin/init
CMD [ "/sbin/init", "3" ]

