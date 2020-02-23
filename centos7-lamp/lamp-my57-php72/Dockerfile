#
# centos7-lamp:lamp-my57-php70
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7-lamp:lamp-my57-php70"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-lamp:lamp AS build-stage

# Labels
LABEL \
 build-stage="true"

# LAMP Environment (CentOS7)
FROM centos:centos7-systemd AS centos7-lamp-stage

# Labels
LABEL \
 name="LAMP(mysql57,php72) Environment on CentOS7 with Systemd" \
 maintainer="MT"

# COPY from build-stage
COPY \
 --from=build-stage / /

# Reset Workdir
WORKDIR \
 /

