#
# centos7-lamp:lamp-default
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7-lamp:lamp-default"
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
 name="LAMP Environment on CentOS7 with Systemd" \
 maintainer="MT"

# COPY from build-stage
COPY \
 --from=build-stage / /

# Reset Workdir
WORKDIR \
 /

