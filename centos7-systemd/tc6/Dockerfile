#
# centos7-systemd:tc6
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-systemd:tc6"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-systemd:java7

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Apache Tomcat6 Server on CentOS7 with Systemd"

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 "${WORKDIR}"

# Install packages for Tomcat
RUN \
 set -x; \
 yum -v -y update && \
 yum -v -y install unzip && \
 yum -v -y clean all

RUN \
 set -x; \
 curl -sL -o apache-tomcat-6.0.48.zip http://ftp.jaist.ac.jp/pub/apache/tomcat/tomcat-6/v6.0.48/bin/apache-tomcat-6.0.48.zip

## Create 'tomcat' user and group
#ARG \
# TC_UID=""
#ARG \
# TCPASSWORD=""
#RUN \
# set -x; . /etc/sysconfig/tomcat && \
# groupadd -g "${TC_UID:-91}" "${TCUSER}" && \
# useradd -u "${TC_UID:-91}" -g "${TCUSER}" -d "${TCHOME}" -m "${TCUSER}" && \
# echo "${TCUSER}:${TCPASSWORD:-$TCUSER}" |chpasswd


# Reset Work dir
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
 docker.run.options="-d -P -h tomcat6-server --privileged" \
 docker.run.confirm-startup=""

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 curl -sL --no-keepalive -o /dev/null "http://localhost/"

# Publish a container's port(s) to the host
EXPOSE 80 443 8080 8443

