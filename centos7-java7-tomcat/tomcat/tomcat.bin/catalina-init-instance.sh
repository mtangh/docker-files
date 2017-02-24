#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

instancename="${TC_INSTANCE:-}"
sysconf_load=0
def_instance=0

while [ $# -gt 0 ]
do
  case "$1" in
  -*)
    ;;
  *)
    if [ -z "$instancename" ]
    then instancename="$1"
    fi
    ;;
  esac
  shift
done

[ -r "${CDIR}/catalina.rc" ] || {
  echo "$THIS: ERROR: 'catalina.rc' is not set." 1>&2
  exit 127
}
. "${CDIR}/catalina.rc" 2>/dev/null || {
  exit $?
}

set -u

cd "${CATALINA_BASE}" && {

  chown -R "root:${TOMCAT_GROUP}" . &&
  find . -type d -exec chmod 2755 {} \; &&
  find . -type f -exec chmod 0644 {} \; &&
  find . -type f -a -name "*.sh" -exec chmod 0755 {} \;

  for dir in \
    conf/Catalina{,/localhost}/ \
    webapps/{deploy,versions}/ \
    logs/ run/ work/ temp/
  do
    ( cd "${dir}" &&
      chown "${TOMCAT_USER}:${TOMCAT_GROUP}" "." &&
      chmod 2755 "." ) 2>/dev/null
  done

  [ -n "${CATALINA_OUT}" ] && {
  
    logrotate_f="/etc/logrotate.d/tomcat"

    [ $def_instance -eq 0 ] && { 
      logrotate_f="${logrotate_f}@${instancename}"
    }

    [ -d "${logrotate_f%/*}" ] &&
    [ ! -e "${logrotate_f}" ] && {

      cat <<_EOF_
$CATALINA_OUT {
 daily
 rotate 30
 missingok
 copytruncate
 create 0644 $TOMCAT_USER $TOMCAT_GROUP
}
_EOF_

    } >"${logrotate_f}"

  }

}

exit 0
