#
# centos7s-tomcat:0
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGEPATH="centos7s-tomcat:0"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#@  DOCKER_PUBLISHED=""
#

FROM centos7s-with-ssh:latest

# Set Workdir
WORKDIR /tmp/docker-container-image-build

# COPY sysconfig file to /etc/sysconfig
COPY tomcat.sysconfig /etc/sysconfig/tomcat
COPY "tomcat@.sysconfig" "/etc/sysconfig/tomcat@"

# COPY systemd files
COPY tomcat*.service "/etc/systemd/system/"
COPY tomcat*.timer "/etc/systemd/system/"

# COPY Setup tools
COPY tomcat*.sh "/usr/local/bin/"

# COPY tomcat.bin
COPY tomcat.bin ./tomcat.bin/

# Install template of instance
COPY "tomcat@/" ./tomcat@/

# tomcat user password
ARG TOMCAT_PASSWORD=""

# Create 'tomcat' user and group
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "Install packages." && { \
  yum -v -y update && \
  yum -v -y install which tar unzip patch && \
  yum -v -y clean all && { \
  rm -rf /var/cache/yum/* || :; }; \
 } && \
 : "SetUp sysconfig." && { \
  chown root:root /etc/sysconfig/tomcat* && \
  chmod 0644 /etc/sysconfig/tomcat*; \
 } && \
 : "SetUp systemd files." && { \
  (cd /etc/systemd/system && \
   chown root:root ./tomcat*.* && \
   chmod 0644 ./tomcat*.* && \
   for systemd_timer in tomcat*.timer; \
   do systemctl enable "${systemd_timer}" || :; \
   done; ); \
 } && \
 : "Install tomcat setup tools." && { \
  (cd /usr/local/bin && \
   chown root:root ./tomcat*.sh && \
   chmod 0644 ./tomcat*.sh; ); \
 } && \
 : "Load sysconfig" && { \
  . /etc/sysconfig/tomcat; \
 } && \
 : "tomcat user and group." && { \
  _tc_usrname="${TOMCAT_USER:-tomcat}"; \
  _tc_grpname="${TOMCAT_GROUP:-$_tc_usrname}"; \
  _tc_homedir="${TOMCAT_HOME:-/opt/$_tc_usrname}"; \
  [ -n "$_tc_usrname" -a -n "$_tc_grpname" -a -n "$_tc_homedir" ]; \
 } || exit 101; \
 : "Create tomcat group." && { \
  egrep "^${_tc_grpname}:" /etc/group &>/dev/null || { \
   for _tc_gnumber in $(seq 91 98 2>/dev/null); \
   do \
    grep -E "^[^:]+:[^:]+:$_tc_gnumber:" /etc/group && continue; \
    groupadd -g "${_tc_gnumber}" "${_tc_grpname}" && break; \
   done; \
  }; \
 } 2>/dev/null && \
 : "Create tomcat user." && { \
  egrep "^${_tc_usrname}:" /etc/passwd &>/dev/null || { \
   for _tc_unumber in $(seq 91 98 2>/dev/null); \
   do \
    grep -E "^[^:]+:[^:]+:$_tc_unumber:" /etc/passwd && continue; \
    useradd -u "${_tc_unumber}" -g "${_tc_grpname}" -d "${_tc_homedir}" -m "${_tc_usrname}" && \
    echo "${_tc_usrname}:${TOMCAT_PASSWORD:-$_tc_usrname}" |chpasswd && \
    break; \
   done; \
  }; \
 } 2>/dev/null && \
 : "SetUp tomcat home dir." && { \
  (cd "${_tc_homedir}/" && { \
    chown "${_tc_usrname}:${_tc_grpname}" . && \
    chmod 0775 . && \
    [ -d ".ssh" ] || { \
     mkdir -p .ssh && \
     chown "${_tc_usrname}:${_tc_grpname}" .ssh && \
     chmod 0700 .ssh; } && \
    for dir in bin instances var work tmp; \
    do \
     [ -d "./${dir}" ] || { mkdir -p "./${dir}"; } && \
     chown "root:${_tc_grpname}" "./${dir}" && \
     chmod 0755 "./${dir}" || exit 102; \
    done; \
    for dir in var/lib var/log var/run work tmp; \
    do \
     [ -d "./${dir}" ] || { mkdir -p "./${dir}"; } && \
     chown "${_tc_usrname}:${_tc_grpname}" "./${dir}" && \
     chmod 2775 "./${dir}" || exit 103; \
    done; \
   }; ); \
 } && \
 : "SetUp 'tomcat.bin'." && { \
  (work_dir=$(pwd); \
   cd "${_tc_homedir}/bin" && { \
    mv -f "${work_dir}/tomcat.bin"/* ./ && \
    chown "root:${_tc_grpname}" ./* && \
    chmod 0755 ./*; }; ); \
 } 2>/dev/null && \
 : "Configure template of instance." && { \
  (work_dir=$(pwd); \
   cd "${_tc_homedir}/instances" && { \
    mv -f "${work_dir}/tomcat@" "./tomcat@" && \
    chown -R "root:${_tc_grpname}" "./tomcat@" && \
    find "./tomcat@" -type d -exec chmod 0755 {} \; && \
    find "./tomcat@" -type f -exec chmod 0644 {} \; && \
    find "./tomcat@" -type f -a -name "*.sh" -exec chmod 0755 {} \; && \
    echo; \
   }; ); \
 } 2>/dev/null && \
 : "YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "Done.";

# Reset Work dir
WORKDIR /

# Labels
LABEL \
 name="Template of Tomcat Server on CentOS7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license="" \
 docker.build.options="" \
 docker.run.options="" \
 docker.run.confirm-startup=""

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR /tmp/docker-container-image-build

# ONBUILD: Copy contents
ONBUILD \
COPY * ./

# ONBUILD: Java package list
ONBUILD \
ARG TC_JAVA_PKG_LIST="./tomcat-java-packages.txt"

# ONBUILD: Tomcat sysconfig parameters
ONBUILD \
ARG JAVA_HOME=""
ONBUILD \
ARG TOMCAT_HOME=""
ONBUILD \
ARG TOMCAT_USER=""
ONBUILD \
ARG TOMCAT_GROUP=""
ONBUILD \
ARG TOMCAT_PASSWORD=""
ONBUILD \
ARG CATALINA_HOME=""
ONBUILD \
ARG CATALINA_BASE=""

# ONBUILD: Download and install tomcat
ONBUILD \
ARG TCPKG_BASE="http://ftp.jaist.ac.jp/pub/apache/tomcat/"
ONBUILD \
ARG TCPKG_PATH=""
ONBUILD \
ARG TC_PKG_URL=""

# ONBUILD: Tomcat instances
ONBUILD \
ARG TC_INSTANCES="tomcat"

# ONBUILD: Update ayaconfig, download and install tomcat,
ONBUILD \
RUN \
 set -ux; \
 work_dir=$(pwd); \
 : "ONBUILD: Update syscnfig" && { \
  bash -vx /usr/local/bin/tomcat-sysconfig.sh \
   -f "/etc/sysconfig/tomcat" \
   "JAVA_HOME=${JAVA_HOME}" \
   "TOMCAT_HOME=${TOMCAT_HOME}" \
   "TOMCAT_USER=${TOMCAT_USER}" \
   "TOMCAT_GROUP=${TOMCAT_GROUP}" \
   "TOMCAT_PASSWORD=${TOMCAT_PASSWORD}" \
   "CATALINA_HOME=${CATALINA_HOME}" \
   "CATALINA_BASE=${CATALINA_BASE}" \
   ; echo; \
 }; \
 : "ONBUILD: Load sysconfig" && { \
  . /etc/sysconfig/tomcat; \
 } && \
 : "ONBUILD: tomcat user and group" && { \
  _tc_usrname="${TOMCAT_USER:-tomcat}"; \
  _tc_grpname="${TOMCAT_GROUP:-$_tc_usrname}"; \
  _tc_homedir="${TOMCAT_HOME:-/opt/$_tc_usrname}"; \
  [ -n "$_tc_usrname" -a -n "$_tc_grpname" -a -n "$_tc_homedir" ]; \
 } || exit 101; \
 : "ONBUILD: Install tomcat" && { \
  if [ -z "${TC_PKG_URL}" ]; \
  then \
   [ -n "${TCPKG_BASE}" ] && \
   TCPKG_BASE=$(echo "$TCPKG_BASE" |sed -e 's#/$##g'); \
   [ -n "${TCPKG_PATH}" ] && \
   TCPKG_PATH=$(echo "$TCPKG_PATH" |sed -e 's#^/##g'); \
   [ -n "${TCPKG_BASE}" -a -n "${TCPKG_PATH}" ] && \
   TC_PKG_URL="${TCPKG_BASE}/${TCPKG_PATH}"; \
  fi; \
  [ -n "${TC_PKG_URL}" ] && { \
   _tc_pkg_file="${TC_PKG_URL##*/}"; \
   _tc_pkg_base="${_tc_pkg_file%.*}"; \
  }; \
  [ -n "$TC_PKG_URL" -a \
    -n "$_tc_pkg_file" -a -n "$_tc_pkg_base" ] || { \
   echo "No build args: 'TC_PKG_URL'." 1>&2; exit 102; }; \
  _tcpkg_cache=$( \
   ls -1r ./"${_tc_pkg_file}" 2>/dev/null | \
   head -n 1); \
  [ -n "${_tcpkg_cache}" ] || { \
   curl -sL -O "${TC_PKG_URL}"; \
  }; \
 } || exit 103; \
 : "ONBUILD: Decompress package" && { \
  (cd "${_tc_homedir}" && { \
    case "$_tc_pkg_file" in \
    *.zip) unzip "${work_dir}/${_tc_pkg_file}" ;; \
    *.tgz) tar -zxvf "${work_dir}/${_tc_pkg_file}" ;; \
    *) echo "Illegal package type: '$_tc_pkg_file'." 1>&2; exit 104 ;; \
    esac && \
    [ -n "$_tc_pkg_base" -a -d "./$_tc_pkg_base" ]; \
   }; ); \
 } || exit 105; \
 : "ONBUILD: SetUp CATALINA_HOME" && { \
  (cd "${_tc_homedir}/${_tc_pkg_base}" && { \
   chown -R root:root . && \
   find . -type d -exec chmod 0755 {} \; && \
   find . -type f -exec chmod 0644 {} \; && \
   find . -type f -a -name "*.sh" -exec chmod 0755 {} \; ; \
   [ -e "${CATALINA_HOME}" ] && { \
   rm -f "${CATALINA_HOME}"; } || :; \
   ln -sf "${_tc_homedir}/${_tc_pkg_base}" "${CATALINA_HOME}"; \
   [ -e "${CATALINA_HOME}" ]; \
  }; ); \
 } || exit 106; \
 : "ONBUILD: Make instance" && { \
  (cd "${_tc_homedir}" || exit 108; \
   for instancename in ${TC_INSTANCES}; \
   do \
    echo "Tomcat instance: $instancename"; \
    [ "${instancename}" = "tomcat" ] || { \
     syscfg_src="${work_dir}/${instancename}.sysconfig"; \
     syscfg_dst="/etc/sysconfig/tomcat@${instancename}"; \
     [ -s "${syscfg_src}" ] && { \
      mv -f "${syscfg_src}" "${syscfg_dst}" && \
      chown root:root "${syscfg_dst}" && \
      chmod 0644 "${syscfg_dst}" || exit 107; \
     }; \
    }; \
    ./bin/catalina-make-instance.sh "${instancename}" || { \
     echo "Failed: ./bin/catalina-make-instance.sh ${instancename}"; \
     exit 109; }; \
    echo "Enabling tomcat instance: $instancename"; \
    [ ! -d "${work_dir}/${instancename}" ] || ( \
     echo "Installing '${work_dir}/${instancename}' to '${_tc_homedir}/instances/${instancename}'."; \
     cd "${work_dir}/${instancename}" && \
     tar -c . |tar -C "${_tc_homedir}/instances/${instancename}" -xvf -; ); \
    if [ "${instancename}" = "tomcat" ]; \
    then servicename="${instancename}.service"; \
    else servicename="tomcat@${instancename}.service"; \
    fi; \
    systemctl enable "${servicename}" || :; \
   done && \
   if [ -r "${work_dir}/setup.sh" ]; \
   then \
    mv -f "${work_dir}/setup.sh" ./bin/ && \
    chown "${_tc_usrname}:${_tc_grpname}" ./bin/setup.sh && \
    chmod 0755 ./bin/setup.sh && ./bin/setup.sh; \
   fi 2>/dev/null; ); \
 } || exit 110; \
 : "ONBUILD: YUM Cleanup." && { \
  yum -v -y clean all || :; \
  [ -d "/var/cache/yum/" ] && \
  rm -rf /var/cache/yum/* || :; \
 } && \
 : "ONBUILD: Cleanup." && { \
  cd /; \
  [ -d "/var/log" ] && for lf in /var/log/*; \
  do [ -s "${lf}" ] && cat /dev/null >"${lf}"; done || :; \
  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \
 } && \
 : "ONBUILD: Done.";

# Reset Work dir
ONBUILD \
WORKDIR /

