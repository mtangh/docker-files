#
# centos7sysd-ssh-on
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS:-} --build-arg NO_SSH_LOGIN="
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS:-} --build-arg NO_LOGMANAGE="
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:7_systemd-onbuild

# Labels
LABEL \
 name="CentOS 7 with System and SSHd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7sysd-ssh-on --privileged" \
 docker.run.confirm-startup=""

