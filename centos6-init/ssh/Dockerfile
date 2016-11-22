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

RUN \
 set -x && \
 yum -y install initscripts MAKEDEV && \
 yum check && \
 yum -y update && \
 yum -y install openssh-server && \
 yum -y clean all

RUN \
 set -x && \
 echo 'root:root' |chpasswd

RUN \
 set -x && \
 groupadd -g 500 dockeruser && \
 useradd -u 500 -g dockeruser -m dockeruser && \
 echo 'dockeruser:dockeruser' |chpasswd

RUN \
 set -x && \
 sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config && \
 sed -ri 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
 cat /etc/ssh/sshd_config

RUN \
 set -x && \
 /etc/init.d/sshd start

# Bind port
EXPOSE 22

# Start /sbin/init
CMD /sbin/init
