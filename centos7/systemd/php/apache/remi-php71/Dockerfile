#
# centos7s-php-apache:remi-php71
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7s-php-apache"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#

# PHP71(REMI) enabled Apache HTTP Server on CentOS7 with Systemd
FROM centos7s-httpd-apache-php:remi-php-onbuild AS remi-php71

# Reset Workdir
WORKDIR /

# Labels
LABEL \
 name="PHP71(REMI) enabled Apache HTTP Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="-d -P -h centos7s-httpd-apache-php71 --privileged" \
 docker.run.confirm-startup=""

