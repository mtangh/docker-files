#
# centos7-init:ssh
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-init:ssh"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h ssh-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos:centos7

# Maintainer
MAINTAINER MT

# Root password
ARG ROOTPASSWD=root

# Default user and passwd
ARG DOCKERUSER=dockeruser
ARG DOCKERPASS=dockeruser

# Install packages
RUN \
 set -x; \
 yum -y install initscripts MAKEDEV && \
 yum check && \
 yum -y update && \
 yum -y install openssh-server sudo && \
 yum -y clean all

# Change root passwor
RUN \
 set -x; \
 echo "root:${ROOTPASSWD:-root}" |chpasswd

# Create default user
RUN \
 set -x; \
 dockeruser="${DOCKERUSER:-dockeruser}"; \
 dockerpass="${DOCKERPASS:-dockeruser}"; \
 groupadd -g 500 "${dockeruser}" && \
 useradd -u 500 -g "${dockeruser}" -m "${dockeruser}" && \
 echo "${dockeruser}:${dockerpass}" |chpasswd

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

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in /tmp/*.log; do rm -f "$log"; done

# STOP SIGNAL
STOPSIGNAL SIGINT

# Publish a container's port(s) to the host
EXPOSE 22

# Start /sbin/init
CMD ["/sbin/init","3"]

