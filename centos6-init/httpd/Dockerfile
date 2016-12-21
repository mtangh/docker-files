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

# Install packages for Apache (and PHP)
RUN \
 set -x; \
 yum -y update && \
 yum -y install httpd mod-ssl && \
 yum -y install php php-pear php-mbstring && \
 yum -y clean all

# Change the httpd.conf
RUN \
 set -x; \
 httpd_conf="/etc/httpd/conf/httpd.conf"; \
 php_ini="/etc/php.ini"; \
 [ -e "${httpd_conf}.ORIG" ] || { cp -pf "${httpd_conf}"{,.ORIG}; }; \
 [ -e "${php_ini}.ORIG" ] || { cp -pf "${php_ini}"{,.ORIG}; }; \
 echo "Update $httpd_conf" && \
 sed -ri 's#^(ServerAdmin)[ ][ ]*.*$#\1 admin@localhost#g' "$httpd_conf" && \
 sed -ri 's#^(ServerTokens)[ ][ ]*.*$#\1 Prod#g' "$httpd_conf" && \
 sed -ri 's#^(ServerSignature)[ ][ ]*.*$#\1 Off#g' "$httpd_conf" && \
 echo "Update $php_ini" && \
 sed -ri \
  's#^(;|)[ ]*mbstring\.(internal_encoding|http_output)[ ]*=[ ]*.*$#mbstring.\2 = UTF-8#g' \
  "${php_ini}" && \
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
WORKDIR \
 /
RUN \
 rm -rf "${WORKDIR}"

# Health check
HEALTHCHECK \
--interval=60s --timeout=15s --retries=3 \
CMD \
 curl -sL --no-keepalive -o /dev/null "http://localhost/"

# Publish a container's port(s) to the host
EXPOSE 80 443

