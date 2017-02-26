#
# centos7-java7-tomcat:tomcat
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-java7-tomcat:tomcat"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-java:java7

# Maintainer
MAINTAINER MT

# Labels
LABEL \
 name="Template of Tomcat Server on CentOS7 with Java7"

# Work dir
ARG \
 WORKDIR=/tmp/workdir
WORKDIR \
 "${WORKDIR}"

# Install packages for Tomcat
RUN \
 set -x; \
 yum -v -y update && \
 yum -v -y install which tar unzip patch logrotate && \
 yum -v -y clean all

# COPY sysconfig file to /etc/sysconfig
COPY \
 tomcat.sysconfig /etc/sysconfig/tomcat
COPY \
 "tomcat@.sysconfig" "/etc/sysconfig/tomcat@"
RUN \
 set -x; \
 chown root:root /etc/sysconfig/tomcat* && \
 chmod 0644 /etc/sysconfig/tomcat*

# Create 'tomcat' user and group
ARG \
 TOMCAT_PASSWORD=""
RUN \
 set -x; . /etc/sysconfig/tomcat && \
 _tc_user="${TOMCAT_USER:-tomcat}" && \
 _tc_group="${TOMCAT_GROUP:-$_tc_user}" && \
 _tc_homedir="${TOMCAT_HOME:-/opt/$_tc_user}" && \
 grep -E "^$_tc_group:" /etc/group 1>/dev/null 2>&1 || { \
  for _tc_gid in 91 92 93 94 95 96 97 98; \
  do \
   grep -E "^[^:]+:[^:]+:$_tc_gid:" /etc/group 1>/dev/null && continue; \
   groupadd -g "${_tc_gid}" "${_tc_group}" && break; \
  done; \
 } 2>/dev/null; \
 grep -E "^$_tc_user:" /etc/passwd 1>/dev/null 2>&1 || { \
  for _tc_uid in 91 92 93 94 95 96 97 98; \
  do \
   grep -E "^[^:]+:[^:]+:$_tc_uid:" /etc/passwd 1>/dev/null && continue; \
   useradd -u "${_tc_uid}" -g "${_tc_group}" -d "${_tc_homedir}" -m "${_tc_user}" && \
   echo "${_tc_user}:${TOMCAT_PASSWORD:-$_tc_user}" |chpasswd && \
   break; \
  done; \
 } 2>/dev/null;

# Setup tomcat home directory
RUN \
 set -x; . /etc/sysconfig/tomcat && \
 _tc_user="${TOMCAT_USER:-tomcat}" && \
 _tc_group="${TOMCAT_GROUP:-$_tc_user}" && \
 _tc_homedir="${TOMCAT_HOME:-/opt/$_tc_user}" && \
 cd "${_tc_homedir}/" && { \
  chown "${_tc_user}:${_tc_group}" . && \
  chmod 0775 . && \
  for dir in bin instances var; \
  do \
   [ -d "./${dir}" ] || { \
    mkdir -p "./${dir}"; } && \
   chown "root:${_tc_group}" "./${dir}" && \
   chmod 0755 "./${dir}"; \
  done; \
  for dir in var/lib var/log var/run; \
  do \
   [ -d "./${dir}" ] || { \
    mkdir -p "./${dir}"; } && \
   chown "${_tc_user}:${_tc_group}" "./${dir}" && \
   chmod 2755 "./${dir}"; \
  done; \
 } 2>/dev/null;

# Install systemd service files
COPY \
 tomcat*.service /etc/systemd/system/
COPY \
 tomcat*.timer /etc/systemd/system/
COPY \
 logrotate.* /etc/systemd/system/
RUN \
 set -x; . /etc/sysconfig/tomcat && \
 chown root:root /etc/systemd/system/tomcat*.service && \
 chmod 0644 /etc/systemd/system/tomcat*.service && \
 chown root:root /etc/systemd/system/tomcat*.timer && \
 chmod 0644 /etc/systemd/system/tomcat*.timer && \
 chown root:root /etc/systemd/system/logrotate.* && \
 chmod 0644 /etc/systemd/system/logrotate.* && \
 systemctl enable tomcat-cleanup-logs.timer; \
 systemctl enable logrotate.timer; \
 echo

# Install instance templates
COPY \
 "tomcat@/" "${WORKDIR}/tomcat@/"
RUN \
 set -x; . /etc/sysconfig/tomcat && \
 _tc_user="${TOMCAT_USER:-tomcat}" && \
 _tc_group="${TOMCAT_GROUP:-$_tc_user}" && \
 _tc_homedir="${TOMCAT_HOME:-/opt/$_tc_user}" && \
 cd "${_tc_homedir}/instances" && { \
  mv -f "${WORKDIR}/tomcat@" "./tomcat@" && \
  chown -R "root:${_tc_group}" "./tomcat@" && \
  find "./tomcat@" -type d -exec chmod 0755 {} \; && \
  find "./tomcat@" -type f -exec chmod 0644 {} \; && \
  find "./tomcat@" -type f -a -name "*.sh" -exec chmod 0755 {} \; ; \
 } 2>/dev/null;

# Install tomcat tools
COPY \
 tomcat.bin "${WORKDIR}/tomcat.bin/"
RUN \
 set -x; . /etc/sysconfig/tomcat && \
 _tc_user="${TOMCAT_USER:-tomcat}" && \
 _tc_group="${TOMCAT_GROUP:-$_tc_user}" && \
 _tc_homedir="${TOMCAT_HOME:-/opt/$_tc_user}" && \
 cd "${_tc_homedir}/bin" && { \
  mv -f ${WORKDIR}/tomcat.bin/* ./ && \
  chown "root:${_tc_group}" ./* && \
  chmod 0755 ./*; \
 } 2>/dev/null;

# Reset Work dir
WORKDIR /

# Cleanup
RUN \
 set -x; \
 for log in $(find /var/log -type f 2>/dev/null); \
 do [ -f "$log" ] && cat /dev/null 1>"$log"; done 2>/dev/null || :; \
 for log in {,/root,/tmp,/var/tmp}/*.log; \
 do rm -f "$log"; done 2>/dev/null || :; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
 rm -rf "${WORKDIR}"; } || :

#-
#- Begin ONBUILDs
#-

# Work dir
ONBUILD \
ARG \
 WORKDIR=/tmp/workdir
ONBUILD \
WORKDIR \
 "${WORKDIR}"

# Copy contents
ONBUILD \
COPY \
 * "${WORKDIR}/"

# Download and install tomcat
ONBUILD \
ARG \
 TC_URL_BASE="http://ftp.jaist.ac.jp/pub/apache/tomcat/"
ONBUILD \
ARG \
 TC_URL_PATH=""
ONBUILD \
ARG \
 TC_URL=""
ONBUILD \
RUN \
 set -x; . /etc/sysconfig/tomcat && \
 _tc_user="${TOMCAT_USER:-tomcat}" && \
 _tc_group="${TOMCAT_GROUP:-$_tc_user}" && \
 _tc_homedir="${TOMCAT_HOME:-/opt/$_tc_user}"; \
 _tc_arch_file=$(ls -1r ./apache-tomcat-*.{tgz,zip} 2>/dev/null |head -n 1); \
 if [ -n "$_tc_arch_file" ]; \
 then \
  TC_URL="$_tc_arch_file"; \
 else \
  [ -n "$TC_URL" ] || { \
   [ -n "${TC_URL_BASE}" ] && \
   TC_URL_BASE=$(echo "$TC_URL_BASE" |sed -e 's#/$##g'); \ 
   [ -n "${TC_URL_PATH}" ] && \
   TC_URL_PATH=$(echo "$TC_URL_PATH" |sed -e 's#^/##g'); \
   [ -n "${TC_URL_BASE}" ] && \
   [ -n "${TC_URL_PATH}" ] && \
   TC_URL="${TC_URL_BASE}/${TC_URL_PATH}"; \
  }; \
 fi; \
 _tc_install_file="${TC_URL##*/}" && \
 _tc_install_base="${_tc_install_file%.*}" && \
 [ -z "$TC_URL" ] && { \
  echo "No build args: 'TC_URL'."; exit 1; } 1>&2; \
 [ -z "$_tc_install_file" -o -z "$_tc_install_base" ] && { \
  echo "No build args: 'TC_URL'."; exit 2; } 1>&2; \
 [ -n "$_tc_arch_file" ] || curl -s -LO "${TC_URL}"; \
 cd "$_tc_homedir" && { \
  case "$_tc_install_file" in \
  *.zip) unzip "${WORKDIR}/${_tc_install_file}" ;; \
  *.tgz) tar -zxvf "${WORKDIR}/${_tc_install_file}" ;; \
  *) echo "Illegal package type: '$_tc_install_file'." 1>&2; exit 2 ;; \
  esac && \
  [ -n "$_tc_install_base" -a -d "./$_tc_install_base" ]; \
 } 2>/dev/null && \
 cd "$_tc_homedir/$_tc_install_base" && { \
  chown -R root:root . && \
  find . -type d -exec chmod 0755 {} \; && \
  find . -type f -exec chmod 0644 {} \; && \
  find . -type f -a -name "*.sh" -exec chmod 0755 {} \; ; \
 } 2>/dev/null; \
 [ -e "${CATALINA_HOME}" ] && { \
  [ -d "${CATALINA_HOME}" ] || rm -f "${CATALINA_HOME}"; \
  [ -d "${CATALINA_HOME}" ] && rm -rf "${CATALINA_HOME}"; \
 } 2>/dev/null; \
 [ -e "${CATALINA_HOME}" ] || { \
  ln -sf "$_tc_homedir/$_tc_install_base" "${CATALINA_HOME}"; \
  [ -e "${CATALINA_HOME}" ] || exit 3; \
 } 2>/dev/null;

# Setup default tomcat instance
ONBUILD \
ARG \
 TC_INSTANCES="tomcat"
ONBUILD \
RUN \
 set -x; . /etc/sysconfig/tomcat; \
 _tc_user="${TOMCAT_USER:-tomcat}" && \
 _tc_group="${TOMCAT_GROUP:-$_tc_user}" && \
 _tc_homedir="${TOMCAT_HOME:-/opt/$_tc_user}"; \
 for instancename in ${TC_INSTANCES}; \
 do \
  [ -r "${WORKDIR}/${instancename}.sysconfig" ] && \
  mv -f "${WORKDIR}/${instancename}.sysconfig" "/etc/sysconfig/tomcat@${instancename}"; \
 done 2>/dev/null; \
 cd "${_tc_homedir}" && { \
  for instancename in ${TC_INSTANCES}; \
  do \
   echo "instancename=$instancename"; \
   ./bin/catalina-mkinstance.sh "${instancename}" && { \
    echo "Enabling tomcat instance: $instancename"; \
    [ ! -d "${WORKDIR}/${instancename}" ] || ( \
     cd "${WORKDIR}/${instancename}" && \
     tar -cv . |tar -C "${_tc_homedir}/instances/${instancename}" -xf -; \
    ); \
    servicename=""; \
    [ "${instancename}" = "tomcat" ] && \
    servicename="${instancename}.service"; \
    [ "${instancename}" = "tomcat" ] || \
    servicename="tomcat@${instancename}.service"; \
    systemctl enable "${servicename}"; \
   }; \
  done && \
  [ ! -r "${WORKDIR}/setup.sh" ] || { \
   mv -f "${WORKDIR}/setup.sh" ./bin/ && \
   chown "${_tc_user}:${_tc_group}" ./bin/setup.sh && \
   chmod 0755 ./bin/setup.sh && \
   ./bin/setup.sh; \ 
  }; \
 } 2>/dev/null;

# Reset Work dir
ONBUILD \
WORKDIR /

# Cleanup
ONBUILD \
RUN \
 set -x; \
 for log in $(find /var/log -type f 2>/dev/null); \
 do [ -f "$log" ] && cat /dev/null 1>"$log"; done 2>/dev/null || :; \
 for log in {,/root,/tmp,/var/tmp}/*.log; \
 do rm -f "$log"; done 2>/dev/null || :; \
 [ -n "${WORKDIR}" -a -d "${WORKDIR}" ] && { \
 rm -rf "${WORKDIR}"; } || :

#-
#- End of ONBUILDs
#-

# Labels for run
LABEL \
 docker.run.options="-d -P -h tomcat --privileged" \
 docker.run.confirm-startup=""

