#
# centos7sysd-ssh-off
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS:-} --build-arg NO_SSH_LOGIN=YES"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS:-} --build-arg NO_LOGMANAGE=YES"
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:7_systemd-onbuild

# Labels
LABEL \
 name="CentOS 7 Systemd, no SSHd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7sysd-ssh-off --privileged" \
 docker.run.confirm-startup=""

