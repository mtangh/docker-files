#
# centos7s-httpd-apache-php
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7s-httpd-apache-php"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#

# PHP56(REMI) enabled Apache HTTP Server on CentOS7 with Systemd
FROM centos7s-httpd-apache-php:remi-php-onbuild AS remi-php56

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="PHP56(REMI) enabled Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-httpd-apache-php56 --privileged" \
 docker.run.confirm-startup=""

