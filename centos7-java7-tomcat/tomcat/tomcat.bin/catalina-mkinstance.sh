#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

instancename="${TC_INSTANCE:-}"
instancesdir="${TC_INSTANCES_DIR:-}"
template_dir="${TC_INSTANCE_TEMPLATE:-}"

# Parsing options
while [ $# -gt 0 ]
do
  case "$1" in
  -i*|--instances-dir*)
    if [ -n "${1##*--}" -a -n "${1##*=}" ]
    then instancesdir="${1##*=}"
    elif [ -z "${1##*--}" -a -n "${1##*-i}" ]
    then instancesdir="${1##*-i}" ]
    else instancesdir="$2"; shift
    fi
    ;;
  -t*|--template-dir*)
    if [ -n "${1##*--}" -a -n "${1##*=}" ]
    then template_dir="${1##*=}"
    elif [ -z "${1##*--}" -a -n "${1##*-t}" ]
    then template_dir="${1##*-t}" ]
    else template_dir="$2"; shift
    fi
    ;;
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

# Set the default
[ -n "${instancesdir}" ] ||
instancesdir="${TOMCAT_HOME}/instances"
[ -n "${template_dir}" ] ||
template_dir="${instancesdir}/tomcat@"

# Mkdirs
[ -d "${instancesdir}" ] ||
mkdir -p "${instancesdir}" 2>/dev/null
[ -d "${template_dir}" ] ||
mkdir -p "${template_dir}" 2>/dev/null

# Instance base directory
if [ -n "${instancename}" ] &&
   [ ! -r "/etc/sysconfig/tomcat@${instancename}" ]
then
  # CATALINA_BASE
  CATALINA_BASE="${instanesdir}/${instancename}"
  # Create a sysconfig of instance
  if [ -r "/etc/sysconfig/tomcat@" ]
  then
    cat "/etc/sysconfig/tomcat@" |
    sed -e 's%^\(CATALINA_BASE\)=[^ ].*$%\1='"${CATALINA_BASE}"'%g' \
        1>"/etc/sysconfig/tomcat@${instancename}" 2>/dev/null &&
    # Load the sysconfig of instance
    . "/etc/sysconfig/tomcat@${instancename}" || {
      echo "$THIS: ERROR: '/etc/sysconfig/tomcat@$instancename' not loaded." 1>&2
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
# Tomcat user and home dir.
TOMCAT_USER=$TOMCAT_USER
TOMCAT_HOME=$TOMCAT_HOME
# Where your tomcat installation lives.
CATALINA_HOME=$CATALINA_HOME
CATALINA_BASE=$CATALINA_BASE

_EOF_

  # Cloaning templates to CATALIBA_BASE
  [ -d "${template_dir}" ] && {
    echo "Expand the template '${template_dir}'."
    ( cd "${template_dir}" &&
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
    echo "$file" |grep -E '.*\.bat$' 1>&2 && continue
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
    echo "$file" |grep -E '.*\.bat$' 1>&2 && continue
    echo "Copy '${file}' to '${filepath##*/}/${filename}'."
    cp -f "${file}" "./${filepath##*/}/${filename}"
  done

  # Symlinking the work directory
  for symlnk in \
    logs:log/${instancename:+tomcat} \
    run:run/${instancename:+tomcat} \
    work:lib/${instancename:+tomcat}/work \
    temp:lib/${instancename:+tomcat}/temp
  do
    symlnk_to="${symlnk%:*}"
    symlnksrc="${TOMCAT_HOME}/var/${symlnk##*:}"
    [ -e "./${symlnk_to}" ] && continue
    [ -d "${symlnksrc}" ] || mkdir -p "${symlnksrc}"
    echo "Symlinked '${symlnksrc}' to '${symlnk_to}'."
    ln -sf "${symlnksrc}" "./${symlnk_to}"
  done

  # Setenv.sh
  [ -n "${instancename}" -a -r "./bin/setenv.sh" ] && {

    diff "${template_dir}/bin/setenv.sh" ./bin/setenv.sh 1>/dev/null && {

      tmp_setenv_sh="./bin/.setenv.$$"

      cat "./bin/setenv.sh" |
      sed -e 's/^\(#* *| *\)\(INSTANCENAME\)=[^=].*$/\2='"$instancename"'/g' \
          1>"${tmp_setenv_sh}" 2>/dev/null &&
      mv -f "${tmp_setenv_sh}" "./bin/setenv.sh"

    }

  } # [ -n "${instancename} -a -r "./bin/setenv.sh" ] &&

  # Server.xml
  [ -r "./conf/server.xml" ] && {

    [ -e "./conf/server.xml.ORIG" ] || {
      cp -pf ./conf/server.xml{,.ORIG}
    }

    cat ./conf/server.xml.ORIG |
    sed -e 's%="8005"%="${catalina.port.shutdown}"%g'  \
        -e 's%="8009"%="${catalina.port.ajp}"%g' \
        -e 's%="8080"%="${catalina.port.http}"%g'  \
        -e 's%="8443"%="${catalina.port.https}"%g' \
        -e 's%\(appBase\)="webapps"%\1="${catalina.webapps.dir}"%g' \
        1>./conf/server.xml
    [ $? -eq 0 ] && {
      echo "Fixed 'server.xml'."
      diff -u ./conf/server.xml{.ORIG,}
    }

  } # [ -r "./conf/server.xml" ] &&

  # Executing the instance initializer
  [ -e "${CDIR}/catalina-init-instance.sh" ] && {
    ${CDIR}/catalina-init-instance.sh "${instancename:+tomcat}" ||
    exit $?
  } # [ -e "${CDIR}/catalina-init-instance.sh" ]

} 2>/dev/null |
while read stdoutln
do
  echo "$THIS: $stdoutln"
done

# end of script
exit 0
