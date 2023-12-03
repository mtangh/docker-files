#
# centos7s-php-apache:remi-php72
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7s-php-apache"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#

# PHP72(REMI) enabled Apache HTTP Server on CentOS7 with Systemd
FROM centos7s-httpd-apache-php:remi-php-onbuild AS remi-php72

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="PHP72(REMI) enabled Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-httpd-apache-php72 --privileged" \
 docker.run.confirm-startup=""

