#
# centos6-init:ssh
#
#@  DOCKER_TAG="centos6-init:ssh"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h ssh-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos:centos6

# Maintainer
MAINTAINER MT

# Root password
ARG ROOTPASSWD="root"

# Default user and passwd
ARG DOCKERUSER=dockeruser
ARG DOCKERPASS=dockeruser

# Work dir.
ARG \
 workdir=/tmp/workdir
WORKDIR \
 "${workdir}"

RUN \
 set -x; \
 yum -y install initscripts MAKEDEV && \
 yum check && \
 yum -y update && \
 yum -y install openssh-server sudo && \
 yum -y clean all

RUN \
 set -x; \
 echo "root:${ROOTPASSWD:-root}" |chpasswd

RUN \
 set -x; \
 dockeruser="${DOCKERUSER:-dockeruser}"; \
 dockerpass="${DOCKERPASS:-dockeruser}"; \
 groupadd -g 500 "${dockeruser}" && \
 useradd -u 500 -g "${dockeruser}" -m "${dockeruser}" && \
 echo "${dockeruser}:${dockerpass}" |chpasswd

RUN \
 set -x; \
 sshd_config="/etc/ssh/sshd_config"; \
 sed -ri 's/^#PermitRootLogin[ ]*yes/PermitRootLogin yes/' "${sshd_config}" && \
 sed -ri 's/^UsePAM yes/UsePAM no/' "${sshd_config}" && \
 cat /etc/ssh/sshd_config

RUN \
 set -x; \
 sudoers="/etc/sudoers"; \
 newline="# For docker user\n${DOCKERUSER:-dockeruser}\tALL=(ALL)\tALL"; \
 sed -ri '/^root[ \t]*ALL.*$/a '"${newline}" "${sudoers}"

RUN \
 set -x; \
 /sbin/chkconfig --add sshd 1>/dev/null 2>&1 || : ; \
 /sbin/chkconfig --levels 2345 sshd on 1>/dev/null 2>&1 || : ;

# Bind port
EXPOSE 22

# Start /sbin/init
CMD /sbin/init
