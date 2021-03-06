#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# Name
THIS="${THIS:-catalina-mkinstance.sh}"
BASE="${THIS%.*}"

# awk
AWK="${AWK:-$(type -P gawk)}"
AWK="${AWK:-$(type -P awk)}"

# sed
SED="${SED:-$(type -P gsed)}"
SED="${SED:-$(type -P sed)}"

# Vars
INSTANCENAME="${TC_INSTANCE:-}"
INSTANCESDIR="${TC_INSTANCES_DIR:-}"
TEMPLATE_DIR="${TC_INSTANCE_TEMPLATE:-}"

# Parsing options
while [ $# -gt 0 ]
do
  case "$1" in
  -i*|--instances-dir*)
    if [ -n "${1##*--}" -a -n "${1##*=}" ]
    then INSTANCESDIR="${1##*=}"
    elif [ -z "${1##*--}" -a -n "${1##*-i}" ]
    then INSTANCESDIR="${1##*-i}" ]
    else INSTANCESDIR="$2"; shift
    fi
    ;;
  -t*|--template-dir*)
    if [ -n "${1##*--}" -a -n "${1##*=}" ]
    then TEMPLATE_DIR="${1##*=}"
    elif [ -z "${1##*--}" -a -n "${1##*-t}" ]
    then TEMPLATE_DIR="${1##*-t}" ]
    else TEMPLATE_DIR="$2"; shift
    fi
    ;;
  -*)
    ;;
  *)
    if [ -z "$INSTANCENAME" ]
    then INSTANCENAME="$1"
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
. "${CDIR}/catalina.rc" 1>/dev/null || {
  exit $?
}

# Set the default
[ -n "${INSTANCESDIR}" ] ||
INSTANCESDIR="${TOMCAT_HOME}/instances"
[ -n "${TEMPLATE_DIR}" ] ||
TEMPLATE_DIR="${INSTANCESDIR}/tomcat@"

# Mkdirs
[ -d "${INSTANCESDIR}" ] ||
mkdir -p "${INSTANCESDIR}" 2>/dev/null
[ -d "${TEMPLATE_DIR}" ] ||
mkdir -p "${TEMPLATE_DIR}" 2>/dev/null

# Instance base directory
if [ -n "${INSTANCENAME}" ] &&
   [ ! -r "/etc/sysconfig/tomcat@${INSTANCENAME}" ]
then
  # CATALINA_BASE
  CATALINA_BASE="${INSTANCESDIR}/${INSTANCENAME}"
  # Create a sysconfig of instance
  if [ -r "/etc/sysconfig/tomcat@" ]
  then
    cat "/etc/sysconfig/tomcat@" |
    $SED -e 's%^(CATALINA_BASE)=[^ ].*$%\1='"${CATALINA_BASE}"'%g' \
        1>"/etc/sysconfig/tomcat@${INSTANCENAME}" 2>/dev/null
    # Load the sysconfig of instance
    . "/etc/sysconfig/tomcat@${INSTANCENAME}" || {
      echo "$THIS: ERROR: '/etc/sysconfig/tomcat@$INSTANCENAME' not loaded." 1>&2
      exit 126
    }
  fi
fi

# Set the shell flags
set -u

# Mkdir CATALINA_BASE if not exists
[ -d "${CATALINA_BASE}" ] || {
  mkdir -p "${CATALINA_BASE}" 1>/dev/null 2>&1
}

# main
cd "${CATALINA_BASE}" && {

  cat <<_EOF_
# Instance name
INSTANCENAME=$INSTANCENAME

# Tomcat user and home dir.
TOMCAT_USER=$TOMCAT_USER
TOMCAT_HOME=$TOMCAT_HOME

# Where your tomcat installation lives.
CATALINA_HOME=$CATALINA_HOME
CATALINA_BASE=$CATALINA_BASE

_EOF_

  # Cloaning templates to CATALIBA_BASE
  [ -d "${TEMPLATE_DIR}" ] && {
    echo "Expand the template '${TEMPLATE_DIR}'."
    ( cd "${TEMPLATE_DIR}" &&
      tar -pc . |tar -C "${CATALINA_BASE}" -xvf - )
  }

  # Mkdirs
  for dir in bin conf{,/Catalina/localhost} lib webapps/{deploy,versions}
  do
    [ -d "./${dir}" ] || {
      echo "Make directory '${dir}'."
      mkdir -p "./${dir}"
    }
  done

  # Symlinking the tc-* commands
  for file in "${TOMCAT_HOME}"/bin/tc-* "${TOMCAT_HOME}"/bin/tomcat*.rc
  do
    filepath="${file%/*}"
    filename="${file##*/}"
    [ -d "${file}" ] && continue
    [ -e "./${filepath##*/}/${filename}" ] && continue
    echo "Symlinked '${file}' to '${filepath##*/}/${filename}'."
    ln -sf "${file}" "./${filepath##*/}/${filename}"
  done

  # Symlinking the CATALINA_HOME/bin commands
  for file in "${CATALINA_HOME}"/bin/*.sh
  do
    filepath="${file%/*}"
    filename="${file##*/}"
    [ -d "${file}" ] && continue
    [ -e "./${filepath##*/}/${filename}" ] && continue
    echo "$file" |egrep '.*\.bat$' 1>&2 && continue
    echo "Symlinked '${file}' to '${filepath##*/}/${filename}'."
    ln -sf "${file}" "./${filepath##*/}/${filename}"
  done

  # Coping the CATALINA_HOME/conf files
  for file in "${CATALINA_HOME}"/conf/*.*
  do
    filepath="${file%/*}"
    filename="${file##*/}"
    [ -d "${file}" ] && continue
    [ -e "./${filepath##*/}/${filename}" ] && continue
    echo "$file" |egrep '.*\.bat$' 1>&2 && continue
    echo "Copy '${file}' to '${filepath##*/}/${filename}'."
    cp -f "${file}" "./${filepath##*/}/${filename}"
  done

  # Symlinking the work directory
  for symlnk in \
    logs:log/${INSTANCENAME:-tomcat} \
    run:run/${INSTANCENAME:-tomcat} \
    work:lib/${INSTANCENAME:-tomcat}/work \
    temp:lib/${INSTANCENAME:-tomcat}/temp
  do
    symlnk_to="${symlnk%:*}"
    symlnksrc="${TOMCAT_HOME}/var/${symlnk##*:}"
    [ -e "./${symlnk_to}" ] && continue
    [ -d "${symlnksrc}" ] || mkdir -p "${symlnksrc}"
    echo "Symlinked '${symlnksrc}' to '${symlnk_to}'."
    ln -sf "${symlnksrc}" "./${symlnk_to}"
  done

  # Setenv.sh
  [ -n "${INSTANCENAME}" -a -r "./bin/setenv.sh" ] && {

    diff "${TEMPLATE_DIR}/bin/setenv.sh" ./bin/setenv.sh 1>/dev/null && {

      tmp_setenv_sh="./bin/.setenv.$$"

      : && {
        cat "./bin/setenv.sh" |
        $SED -re 's/^(#* *| *)(INSTANCENAME)=[^=].*$/\2='"$INSTANCENAME"'/g'
      } 1>"${tmp_setenv_sh}" 2>/dev/null &&
      mv -f "${tmp_setenv_sh}" "./bin/setenv.sh"

    }

  } # [ -n "${INSTANCENAME} -a -r "./bin/setenv.sh" ] &&

  # Server.xml
  [ -r "./conf/server.xml" ] && {

    [ -e "./conf/server.xml.ORIG" ] || {
      cp -pf ./conf/server.xml{,.ORIG}
    }

    : && {
      cat ./conf/server.xml.ORIG |
      $SED -r \
        -e 's%="8005"%="${catalina.port.shutdown}"%g'  \
        -e 's%="8009"%="${catalina.port.ajp}"%g' \
        -e 's%="8080"%="${catalina.port.http}"%g'  \
        -e 's%="8443"%="${catalina.port.https}"%g' \
        -e 's%(appBase)="webapps"%\1="${catalina.webapps.dir}"%g'
    } 1>./conf/server.xml
    [ $? -eq 0 ] && {
      echo "Fixed 'server.xml'."
      diff -u ./conf/server.xml{.ORIG,}
    }

  } # [ -r "./conf/server.xml" ] &&

  # Executing the instance initializer
  [ -e "${CDIR}/catalina-init-instance.sh" ] && {
    ${CDIR}/catalina-init-instance.sh "${INSTANCENAME:-tomcat}" ||
    exit $?
  } # [ -e "${CDIR}/catalina-init-instance.sh" ]

} 2>/dev/null |
$AWK '{printf("%s: %s\n","'"${BASE}"'",$0);fflush();};' |
$SED -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g'

# end of script
exit 0
