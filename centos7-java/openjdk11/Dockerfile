#
# centos7-java:openjdk11
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-java:openjdk11"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-systemd

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Java-JDK11 on CentOS7 with Systemd"

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 "${WORKDIR}"

# Install packages
RUN \
 set -x; \
 yum -y update && \
 yum -y install \
  java-11-openjdk java-11-openjdk-devel \
  java-11-openjdk-headless java-11-openjdk-jmods && \
 yum -y clean all

# Work dir reset
WORKDIR /

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
 docker.run.options="-d -P -h openjdk11 --privileged" \
 docker.run.confirm-startup=""

