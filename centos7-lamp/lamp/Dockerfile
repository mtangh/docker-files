#
# centos7-lamp:lamp
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7-lamp:lamp"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-httpd:apache AS build-stage

# Labels
LABEL \
 build-stage="true"

# LAMP Environment (CentOS7)
FROM centos:centos7-systemd AS centos7-lamp-stage

# Labels
LABEL \
 name="Base image for LAMP Environment on CentOS7 with Systemd" \
 maintainer="MT"

# COPY from build-stage
COPY \
 --from=build-stage / /

# Reset Workdir
WORKDIR \
 /

# Work dir
ONBUILD \
ARG \
 WORKDIR="/tmp/workdir"
ONBUILD \
WORKDIR \
 ${WORKDIR}

# Copy contents
ONBUILD \
COPY \
 * "${WORKDIR}/"

# Setup
ONBUILD \
RUN \
 set -ux; \
 : "ONUILD: Install LAMP Packages" && { \
  if [ -e "./install.sh" ]; \
  then bash ./install.sh; \
  else \
   yum -v -y update && \
   yum -v -y install php php-devel php-pear && \
   yum -v -y install php-mbstring php-pdo php-gd php-xml php-json php-mcrypt php-pecl-zip && \
   yum -v -y install mariadb mariadb-server php-mysqlnd && \
   yum -v -y clean all && \
   systemctl enable mariadb.service && \
   echo; \
  fi && \
  php_ini_file="/etc/php.ini" && \
  : "Update ${php_ini_file}" && { \
   { [ -e "${php_ini_file}.ORIG" ] || cp -pf "${php_ini_file}"{,.ORIG}; }; \
   if [ -e "./php.ini" -a -s "./php.ini" ]; \
   then \
    cat "./php.ini" 1>"${php_ini_file}"; \
   else \
    sed -ri \
    's#^(;|)[ ]*mbstring\.(internal_encoding|http_output)[ ]*=[ ]*.*$#mbstring.\2 = UTF-8#g' \
    "${php_ini_file}" && \
    echo; \
   fi && \
   /usr/sbin/httpd -t && \
   echo; \
  } && \
  mysqlcnffile="/etc/my.cnf" && \
  : "Update ${mysqlcnffile}" && { \
   { [ -e "${mysqlcnffile}.ORIG" ] || cp -pf "${mysqlcnffile}"{,.ORIG}; }; \
   if [ -e "./my.cnf" -a -s "./my.cnf" ]; \
   then \
    cat "./my.cnf" 1>"${mysqlcnffile}"; \
   else \
    sed -ri '/^socket=/a character-set-server=utf8' "${mysqlcnffile}" && \
    echo; \
   fi && \
   echo; \
  } && \
  echo; \
 } && \
 echo;

# Reset Work dir
ONBUILD \
WORKDIR /

