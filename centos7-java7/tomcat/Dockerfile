#
# centos7-java7:tomcat-onbuild
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos7-java7:tomcat-onbuild"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos7-systemd:java7

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
 yum -v -y install which tar unzip patch && \
 yum -v -y clean all

# Tomcat service name
ARG \
 TC_SERVICENAME=tomcat
RUN \
 set -x; \
 [ -n "$TC_SERVICENAME" ] || \  
 echo "No build args: 'TC_SERVICENAME'. 1>&2 && exit 1

# COPY sysconfig file to /etc/sysconfig
COPY \
 tomcat.sysconfig /etc/sysconfig/tomcat
COPY \
 tomcat@.sysconfig /etc/sysconfig/tomcat@
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
 _tc_group=${TOMCAT_GROUP:-$_tc_user}" && \
 _tc_homedir="${TOMCAT_HOME:-/opt/$tc_user}" && \
 grep -E "^$_tc_group:" /etc/group 1>/dev/null 2>&1 || {
  for _tc_gid in 91 92 93 94 95 96 97 98; \
  do \
   grep -E "^[^:]+:[^:]+:$_tc_gid:" /etc/group 1>/dev/null && continue; \
   groupadd -g "${_tc_gid}" "${_tc_group}" && break; \
  done; \
 } 2>/dev/null; \
 grep -E "^$_tc_user:" /etc/passwd 1>/dev/null 2>&1 || {
  for _tc_uid in 91 92 93 94 95 96 97 98; \
  do \
   grep -E "^[^:]+:[^:]+:$_tc_uid:" /etc/passwd 1>/dev/null && continue; \
   useradd -u "${_tc_uid}" -g "${_tc_group}" -d "${_tc_homedir}" -m "${_tc_user}" && \
   echo "${_tc_user}:${TOMCAT_PASSWORD:-$_tc_user}" |chpasswd && \
   break; \
  done; \
 } 2>/dev/null; \
 cd "${_tc_homedir}/" && { \
  for dir in var/lib var/log var/run; \
  do \
   [ -d "./${dir}/${_tc_user}" ] || { \
    mkdir -p "./${dir}/${_tc_user}/"; } && \
   chown -R "${_tc_user}:${_tc_user}" "./${dir}/${_tc_user}/" && \
   chmod 2775 "./${dir}/${_tc_user}/" && \
   ln -sf "${_tc_homedir}/$dir" "/$dir/${_tc_user}"; \
  done 2>/dev/null; \
 }

# Download and install tomcat
ARG \
 tomcat_url=""
RUN \
 set -x; . /etc/sysconfig/tomcat && \
 tomcat_file="${tomcat_url##*/}" && \
 tomcat_base="${tomcat_file%*.}" && \
 [ -z "$tomcat_url" -o -z "$tomcat_file" -o -z "$tomcat_base" ] && { \
  echo "No build args: 'tomcat_url'."; exit 1; } 1>&2; \
 curl -s -LO "${tomcat_url}" && \
 cd "$TOMCAT_HOME" && { \
  case "$tomcat_file" in \
  *.zip) unzip "${WORKDIR}/${tomcat_file}" ;; \
  *.tgz) tar -zxvf "${WORKDIR}/${tomcat_file}" ;; \
  *) echo "Illegal package type: $tomcat_file" 1>&2; exit 2 ;; \
  esac &&
  [ -n "$tomcat_base" -a -d "$TOMCAT_HOME/$tomcat_base" ]; \
 } && \
 cd "$TOMCAT_HOME/$tomcat_base" && { \
  chown -R root:root . &&
  find . -type d -exec chmod 0755 {} \; && \
  find . -type f -exec chmod 0644 {} \; && \
  find . -type f -a -name "*.sh" -exec chmod 0755 {} \; && \
  echo; \
 } && \
 [ -e "${CATALINA_HOME}" ] && { \
  [ -d "${CATALINA_HOME}" ] || rm -f "${CATALINA_HOME}"; \
  [ -d "${CATALINA_HOME}" ] && rm -rf "${CATALINA_HOME}"; \
 } 1>/dev/null 2>&1 || : && \
 [ -e "${CATALINA_HOME}" ] || { \
  ln -sf "${TOMCAT_HOME}/$tomcat_base" "${CATALINA_HOME}" && \
  [ -e "${CATALINA_HOME}" ]; \
 }

# Setup default tomcat instance
COPY \
 tomcat/ ${WORKDIR}/tomcat/
RUN \
 set -x; . /etc/sysconfig/tomcat && \
 for servicename in $TC_SERVICENAME; \
 do \
  ([ -r "/etc/sysconfig/${servicename}" ] && \
   . "/etc/sysconfig/${servicename}"; \
   cp -rf ./tomcat/ "${TOMCAT_HOME}/${servicename}/" && \
   cd "${TOMCAT_HOME}" && {
    for dir in var/lib var/log var/run; \
    do \
     [ -d "./${dir}/${servicename}" ] || { \
      mkdir -p "./${dir}/${servicename}"; } && \
     chown -R "${TOMCAT_USER}:${TOMCAT_USER}" "./${dir}/${servicename}/" && \
     chmod 2775 "./${dir}/${servicename}/"; \
    done && \
    for dir in work temp; \
    do \
     [ -d "./var/lib/${servicename}/$dir" ] || { \
      mkdir -p "./var/lib/${servicename}/$dir"; } && \
     chown -R "${TOMCAT_USER}:${TOMCAT_USER}" "./var/lib/${servicename}/$dir/" && \
     chmod 2775 "./var/lib/${servicename}/$dir/"; \
    done
   } 2>/dev/null; ); \
  ([ -r "/etc/sysconfig/${servicename}" ] && \
   . "/etc/sysconfig/${servicename}"; \
   cd "${TOMCAT_HOME}/${servicename}/" && { \
    chown -R "${TOMCAT_USER}:${TOMCAT_USER}" . && \
    find . -type d -exec chmod 0755 {} \; && \
    find . -type f "*.sh" -exec chmod 0644 {} \; && \
    find . -type f -a -name "*.sh" -exec chmod 0755 {} \; && \
    for dir in $(find ./{conf/Catalina,webapps} -type d 2>/dev/null); \
    do \
     [ -d "./$dir" ] || mkdir -p "./$dir" && \
     chown -R "${TOMCAT_USER}:${TOMCAT_USER}" "./$dir" && \
     chmod 2775 "./$dir"; \
    done 2>/dev/null; && \
    for script in $(find "${CATALINA_HOME}/bin -type f -a -name "*.sh"); \
    do [ -e "./bin/${script#*/}" ] || ln -sf "${script}" ./bin/; done && \
    for conf in $(find "${CATALINA_HOME}/conf -type f); \
    do [ -e "./conf/${conf#*/}" ] || ln -sf "${conf}" ./conf/; done && \
    for symlnk in \
     logs:var/log/${servicename} \
     run:var/run/${servicename} \
     work:var/lib/${servicename}/work \
     temp:var/lib/${servicename}/temp ; \
    do \
     [ -d "${TOMCAT_HOME}/${symlnk##*:}" -a ! -e "./${symlnk%:*}" ] && \
     ln -sf "${TOMCAT_HOME}/${symlnk##*:}" "./${symlnk%:*}"; \
    done; \
   } 2>/dev/null; ); \
 done

# Register systemd
COPY \
 tomcat.service ${WORKDIR}/${TC_SERVICENAME}.service
COPY \
 tomcat.service ${WORKDIR}/${TC_SERVICENAME}.service
RUN \
 set -x; . /etc/sysconfig/{tomcat,$TC_SERVICENAME} && \
 _servicefrom="${WORKDIR}/${TC_SERVICENAME}.service"; \
 _servicefile="/etc/systemd/system/${TC_SERVICENAME}.service"; \
 mv -f "${_servicefrom}" "${_servicefile}" && \
 chown root:root "$_servicefile" && \
 chmod 0644 "$_servicefile"

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

# Labels for run
LABEL \
 docker.run.options="-d -P -h tc-onbuild --privileged" \
 docker.run.confirm-startup=""

