#
# centos7s-without-ssh
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH=""
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS:-} --build-arg NO_SSH_LOGIN=YES"
#@  DOCKER_BUILDOPTS="${DOCKER_BUILDOPTS:-} --build-arg NO_LOGMANAGE="
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7:systemd-onbuild AS latest

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="CentOS 7 with Systemd, no SSHd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-without-ssh --privileged" \
 docker.run.confirm-startup=""

