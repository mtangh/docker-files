#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

instancename="${TC_INSTANCE:-}"

# Parsing options
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

# Load the catalina.rc
[ -r "${CDIR}/catalina.rc" ] || {
  echo "$THIS: ERROR: 'catalina.rc' is not set." 1>&2
  exit 127
}
. "${CDIR}/catalina.rc" 2>/dev/null || {
  exit $?
}

# Set the shell flags
set -u

# Mkdir CATALINA_BASE if not exists
[ -d "${CATALINA_BASE}" ] || {
  mkdir -p "${CATALINA_BASE}" 1>/dev/null 2>&1
}

# main
cd "${CATALINA_BASE}" && {

  # Default permissions
  chown -R "root:${TOMCAT_GROUP}" . &&
  find . -type d -exec chmod 2755 {} \; &&
  find . -type f -exec chmod 0644 {} \; &&
  find . -type f -a -name "*.sh" -exec chmod 0755 {} \;

  # Set the writable permissions
  for dir in \
    conf/Catalina{,/localhost}/ \
    webapps/{deploy,versions}/ \
    logs/ run/ work/ temp/
  do
    ( cd "${dir}" &&
      chown "${TOMCAT_USER}:${TOMCAT_GROUP}" "." &&
      chmod 2755 "." ) 2>/dev/null
  done

  # Checking the CATALINA_OUT
  [ -n "${CATALINA_OUT}" -a -d "${CATALINA_OUT%/*}" ] && {

    # loglotate config
    logrotate_f="/etc/logrotate.d/tomcat${instancename:+@}${instancename}"

    # Checking the logrotate conf
    [ -d "${logrotate_f%/*}" -a ! -e "${logrotate_f}" ] && {

      cat <<_EOF_
$CATALINA_OUT {
  daily
  rotate 30
  dateext
  missingok
  notifempty
  copytruncate
  create 0644 $TOMCAT_USER $TOMCAT_GROUP
}
_EOF_

    } 1>"${logrotate_f}"

  } # [ -n "${CATALINA_OUT}" -a -d "${CATALINA_OUT%/*}" ] &&

} 2>/dev/null |
while read stdoutln
do
  echo "$THIS: $stdoutln"
done

# end of script
exit 0
