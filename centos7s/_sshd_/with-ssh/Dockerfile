#
# centos7s-with-ssh
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS:-} --build-arg NO_SSH_LOGIN=''"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS:-} --build-arg NO_LOGMANAGE=''"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#
FROM centos7:systemd-onbuild AS latest

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS 7 with Systemd and SSHd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-with-ssh --privileged" \
 docker.run.confirm-startup=""

