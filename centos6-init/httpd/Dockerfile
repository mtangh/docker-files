#
# centos6-init:httpd
#
#@  DOCKER_TAG="centos6-init:httpd"
#@  DOCKER_BUILDER_OPTS=
#@  DOCKER_STARTUP_OPTS="-h httpd-server"
#@  CONTAINER_NOT_START=""
#@  CONFIRM_STARTUP_CMD=""
#
FROM centos6-init:ssh

# Maintainer
MAINTAINER MT

# OnBuild Trigger
ONBUILD \
 ARG workdir=/tmp/workdir
ONBUILD \
 WORKDIR ${workdir}/www
ONBUILD \
 COPY *.* ${workdir}/www/
ONBUILD \
 RUN \
  set -x; \
  rm -rf "${workdir}/db"
ONBUILD \
 WORKDIR /root
ONBUILD \
 RUN \
  rm -rf "${workdir}"

# Work dir.
ARG \
 workdir=/tmp/workdir
WORKDIR \
 "${workdir}"

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

# Cleanup workdir
WORKDIR \
 /root
RUN \
 rm -rf "${workdir}"

# Bind port
EXPOSE 22 80 443

# Start /sbin/init
CMD /sbin/init
