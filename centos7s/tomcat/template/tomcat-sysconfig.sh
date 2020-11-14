#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# Name
THIS="${THIS:-tomcat-sysconfig.sh}"
BASE="${THIS%.*}"

# awk
AWK="${AWK:-$(type -P gawk)}"
AWK="${AWK:-$(type -P awk)}"

# sed
SED="${SED:-$(type -P gsed)}"
SED="${SED:-$(type -P sed)}"

# postgresql sysconfig
tcsyscfg="/etc/sysconfig/tomcat"

# Temporary file
tcsystmp="${TMPDIR:-/tmp}/tomcat.sysconfig.$(date +'%Y%m%d%H%M%S')"

# trap
trap \
  "rm -rf ${tcsystmp} &>/dev/null || :" \
  EXIT SIGTERM SIGINT SIGQUIT

# Parse options
while [ $# -gt 0 ]
do
  case "$1" in
  [A-Z][A-Z]*=*)
    [ -n "${1%%=*}" -a -n "${1#*=}" ] && {
      eval "${1}"; export "${1%%=*}"
    }
    ;;
  -f*)
    if [ -n "${1##*-f}" ]
    then tcsyscfg="${1##*-f}"
    else shift; tcsyscfg="${1}"
    fi
    ;;
  -*)
    cat <<_USAGE_
Usage: $THIS [-f /path/to/sysconfig] [ENVNAME=VALUE ...]

_USAGE_
    exit 1
    ;;
  *)
    ;;
  esac
  shift
done

# Check
[ -r "$tcsyscfg" ] || {
  echo "$THIS: ERROR: no such file or directory '$tcsyscfg'." 1>&2
  exit 2
}

# Make temp
cat "${tcsyscfg}" >|"${tcsystmp}" 2>/dev/null || {
  echo "$THIS: ERROR: no such file or directory '$tcsyscfg'." 1>&2
  exit 3
}

# Each Env Name and Values
for syscfg_key in \
JAVA_HOME \
TOMCAT_HOME TOMCAT_USER TOMCAT_GROUP TOMCAT_PASSWORD \
CATALINA_HOME CATALINA_BASE
do

  # New value
  syscfg_val="${!syscfg_key}"

  # Old value
  syscfg_old=$(
    cat "${tcsystmp}" |
    $SED -nre 's;^[ ]*'${syscfg_key}'=["]*([^ ][^"]*)["]*[ ]*$;\1;gp'; )

  # Found ?
  cat "${tcsystmp}" |
  egrep '^[ ]*'${syscfg_key}'=' &>/dev/null
  foundincfg=$?

  # Update sysconfig
  [ $foundincfg -eq 0 ] &&
  [ -n "${syscfg_val}" -a "${syscfg_val}" != "${syscfg_old}" ] && {

    # Print old, new
    echo "$THIS: '${syscfg_key}' = '${syscfg_old}' to '${syscfg_val}'."

    # Replace
    $SED -ri \
      's;^[ ]*'${syscfg_key}'=[^ ]+.*$;'${syscfg_key}'="'${syscfg_val}'";g' \
      "${tcsystmp}" || continue
  
  } # [ $foundincfg -eq 0 ] && ...

  # Additional changes
  case "${syscfg_key}" in
  TOMCAT_USER)
    [ -n "${syscfg_val}" -a -n "${syscfg_old}" ] ||
      continue
    [ -z "$(id -u ${syscfg_val} 2>/dev/null)" ] ||
      continue
    [ -n "$(id -u ${syscfg_old} 2>/dev/null)" ] ||
      continue
    usrgrp_old=$(id -gn "${syscfg_old}" 2>/dev/null)
    if [ -x "$(type -P usermod)" ]
    then
      usermod -l "${syscfg_val}" "${syscfg_old}" ||
      echo "$THIS: ${syscfg_key}: Failed to command 'usermod -l ${syscfg_val} ${syscfg_old}'."
    else
      echo "$THIS: ${syscfg_key}: command 'usermod' not found." 1>&2
    fi
    if [ -x "$(type -P chpasswd)" ]
    then
      echo "${syscfg_val}:${TOMCAT_PASSWORD:-$syscfg_val}" |chpasswd ||
      echo "$THIS: ${syscfg_key}: Failed to command 'echo "${syscfg_val}:*" |chpasswd'."
    else
      echo "$THIS: ${syscfg_key}: command 'chpasswd' not found." 1>&2
    fi
    if [ -n "${usrgrp_old}" -a "${usrgrp_old}" = "${syscfg_old}" ]
    then
      if [ -x "$(type -P groupmod)" ]
      then
        groupmod -n "${syscfg_val}" "${syscfg_old}" ||
        echo "$THIS: ${syscfg_key}: Failed to command 'groupmod -n ${syscfg_val} ${syscfg_old}'." 1>&2
      else
        echo "$THIS: ${syscfg_key}: command 'groupmod' not found." 1>&2
      fi
    fi
    ;;
  TOMCAT_GROUP)
    [ -n "${syscfg_old}" ] ||
      syscfg_old=$(id -gn ${TOMCAT_USER} 2>/dev/null)
    [ -n "${syscfg_val}" -a -n "${syscfg_old}" ] ||
      continue
    [ "${syscfg_val}" != "${syscfg_old}" ] ||
      continue
    cat /etc/group |
    egrep '^'${syscfg_val}':' &>/dev/null &&
      continue
    if [ -x "$(type -P groupmod)" ]
    then
      groupmod -n "${syscfg_val}" "${syscfg_old}" ||
      echo "$THIS: ${syscfg_key}: Failed to command 'groupmod -n ${syscfg_val} ${syscfg_old}'." 1>&2
    else
      echo "$THIS: ${syscfg_key}: command 'groupmod' not found." 1>&2
    fi
    ;;
  TOMCAT_PASSWORD)
    [ -n "${TOMCAT_USER}" -a -n "${syscfg_val}" ] ||
      continue
    [ -n "$(id -u ${TOMCAT_USER} 2>/dev/null)" ] ||
      continue
    if [ -x "$(type -P chpasswd)" ]
    then
      echo "${TOMCAT_USER}:${syscfg_val}" |chpasswd ||
      echo "$THIS: ${syscfg_key}: Failed to command 'echo "${TOMCAT_USER}:*" |chpasswd'."
    else
      echo "$THIS: ${syscfg_key}: command 'chpasswd' not found." 1>&2
    fi
    ;;
  TOMCAT_HOME)
    [ -n "${syscfg_val}" -a -n "${syscfg_old}" ] ||
      continue
    [ -d "${syscfg_old}" ] ||
      continue
    dirowner=$(stat -c '%U' "${syscfg_old}" 2>/dev/null)
    if [ -z "$(id -u ${dirowner} 2>/dev/null)" ]
    then
      echo "$THIS: Unknown user '$dirowner'." 1>&2
    elif [ -x "$(type -P usermod)" ]
    then
      usermod -d "${syscfg_val}" -m "${dirowner}" ||
      echo "$THIS: ${syscfg_key}: Failed to command 'usermod -d ${syscfg_val} -m ${dirowner}'." 1>&2
    else
      echo "$THIS: ${syscfg_key}: command 'usermod' not found." 1>&2
    fi
    ;;
  CATALINA_HOME|CATALINA_BASE)
    [ -n "${syscfg_val}" -a -n "${syscfg_old}" ] ||
      continue
    [ ! -e "${syscfg_val}" -o -d "${syscfg_val}" ] ||
      continue
    [ -d "${syscfg_old}" ] ||
      continue
    ( cd "${syscfg_old}" &&
      tar -c . |tar -C "${syscfg_val}" -xvf - 2>/dev/null &&
      rm -rf "${syscfg_old}" 2>/dev/null; ) ||
    echo "$THIS: ${syscfg_key}: Failed to command 'tar -c .|tar -C "${syscfg_val}" -xvf -'." 1>&2
    ;;
  *)
    ;;
  esac

done

# Update check
[ -s "${tcsystmp}" ] &&
diff "${tcsyscfg}" "${tcsystmp}" &>/dev/null || {

  echo
  echo "$THIS: ${tcsyscfg} >>>"

  diff "${tcsyscfg}" "${tcsystmp}" || {
    cat "${tcsystmp}" >|"${tcsyscfg}"
  } &>/dev/null

  echo

} # [ -s "${tcsystmp}" ] && diff "${tcsyscfg}" "${tcsystmp}"

# end
exit 0
