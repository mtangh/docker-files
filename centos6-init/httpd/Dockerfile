#
# centos6-init:httpd
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos6-init:httpd"
#@  DOCKER_BUILDER_OPTS=""
#@  DOCKER_STARTUP_OPTS="-h httpd-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:ssh

# Maintainer
MAINTAINER MT

# OnBuild Trigger
ONBUILD \
ARG \
 WORKDIR=/tmp/workdir
ONBUILD \
WORKDIR \
 ${WORKDIR}/www
ONBUILD \
COPY \
 *.* ${WORKDIR}/www/
ONBUILD \
RUN \
 set -x; \
 rm -rf "${WORKDIR}/db"
ONBUILD \
WORKDIR \
 /
ONBUILD \
RUN \
 rm -rf "${WORKDIR}"

# Work dir
ARG \
 WORKDIR=/tmp/WORKDIR
WORKDIR \
 "${WORKDIR}"

# Install packages for Apache (and PHP)
RUN \
 set -x; \
 yum -y update && \
 yum -y install httpd mod-ssl php && \
 yum -y clean all

# Change the httpd.conf
RUN \
 set -x; \
 httpd_conf="/etc/httpd/conf/httpd.conf"; \
 [ -e "${httpdi_conf}.ORIG" ] || \
 cp -Pf "${httpd_conf}"{,.ORIG}; \
 sed -ri 's#^(ServerAdmin)[ ][ ]*.*$#\1 admin@localhost#g' "$httpd_conf" && \
 sed -ri 's#^(ServerTokens)[ ][ ]*.*$#\1 Prod#g' "$httpd_conf" && \
 sed -ri 's#^(ServerSignature)[ ][ ]*.*$#\1 Off#g' "$httpd_conf" && \
 /usr/sbin/httpd -t

# Add service
RUN \
 set -x; \
 /sbin/chkconfig --add httpd 1>/dev/null 2>&1 || : ; \
 /sbin/chkconfig --levels 2345 httpd on 1>/dev/null 2>&1 || : ;

# Cleanup
RUN \
 set -x; \
 for log in /var/log/*; do cat /dev/null >"$log"; done; \
 for log in /tmp/*.log; do rm -f "$log"; done

# Reset Work dir
ONBUILD \
WORKDIR \
 /
ONBUILD \
RUN \
 rm -rf "${WORKDIR}"

# Publish a container's port(s) to the host
EXPOSE 80 443

