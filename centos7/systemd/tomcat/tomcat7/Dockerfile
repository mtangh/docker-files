#
# centos7-systemd-tomcat:7
#
#@  DOCKER_IMAGEPATH="centos7-systemd-tomcat:7"
#@  DOCKER_IMAGE_VER="v$(date +'%Y%m%d')"
#@  DOCKER_CONTAINER=""
#@  DOCKER_LATEST_IS=""
#@  DOCKER_BUILDOPTS="" # "--platform=linux/amd64"
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}-${DOCKER_IMAGE_VER}"
#@  DOCKER_PUBLISHED="${DOCKER_IMAGEPATH}"
#

# Tomcat Major version
ARG TC_MAJOR_VER=7

# Download and install tomcat
ARG TC_PKG_URL="/tomcat-7/v7.0.92/bin/apache-tomcat-7.0.92.zip"

# Image from
FROM centos7-systemd-tomcat:0

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="Tomcat${TC_MAJOR_VER} Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 org.ugoole.options.docker.build="" \
 org.ugoole.options.docker.run="-d -P -h centos7-systemd-tomcat${TC_MAJOR_VER} --privileged"

# STOP SIGNAL
STOPSIGNAL SIGINT

# Expose
EXPORSE 8009
EXPORSE 8080
EXPORSE 8443

# Volume
VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init", "3" ]

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 . /etc/sysconfig/postgresql && \
 [ -x "${PGROOT}/bin/psql" ] && \
 su - "${PGUSER}" -c "${PGROOT}/bin/psql -l";


