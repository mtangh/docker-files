#
# centos6-init:ssh
#
FROM centos:centos6

RUN \
 yum -y install initscripts MAKEDEV && \
 yum check && \
 yum -y update && \
 yum -y install openssh-server && \
 yum -y clean all

RUN echo 'root:root' |chpasswd

RUN \
 groupadd -g 500 dockeruser && \
 useradd -u 500 -g dockeruser -m dockeruser && \
 echo 'dockeruser:dockeruser' |chpasswd

RUN \
 sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config && \
 sed -ri 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
 cat /etc/ssh/sshd_config

RUN /etc/init.d/sshd start

# Bind port
EXPOSE 22

# Start /sbin/init
CMD /sbin/init
