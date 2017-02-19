#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

instancename="${TC_INSTANCE:-}"
instancesdir="${TC_INSTANCES_DIR:-}"
template_dir="${TC_INSTANCE_TEMPLATE:-}"

def_instance=0

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

[ -n "${instancename}" ] || {
  echo "$THIS: ERROR: Need instance name." 1>&2
  exit 90
}
[ "${instancename}" = "tomcat" ] && {
  def_instance=1
}

. "/etc/sysconfig/tomcat" 2>/dev/null || {
  echo "$THIS: ERROR: '/etc/sysconfig/tomcat' not found." 1>&2
  exit 91
}

[ $def_instance -eq 0 ] &&
. "/etc/sysconfig/tomcat@${instancename}" 2>/dev/null || :

[ -n "$TOMCAT_USER" -a -n "$TOMCAT_HOME" -a -n "$CATALINA_HOME" ] || {
  echo "$THIS: ERROR: 'One or more variables have not been set yet; TOMCAT_USER/TOMCAT_HOME/CATALINA_HOME." 1>&2
  exit 92
}
[ -d "$TOMCAT_HOME" ] || {
  echo "$THIS: ERROR: TOMCAT_HOME=$TOMCAT_HOME is not a directory." 1>&2
  exit 93
}
[ -d "$CATALINA_HOME" ] || {
  echo "$THIS: ERROR: CATALINA_HOME=$CATALINA_HOME is not a directory." 1>&2
  exit 94
}

[ -r "/etc/sysconfig/tomcat@${instancename}" ] || {
  CATALINA_BASE="${TOMCAT_HOME}/instances/${instancename}"
}

[ -n "${instancesdir}" ] || {
  instancesdir="${TOMCAT_HOME}/instances"
}
[ -n "${template_dir}" ] || {
  template_dir="${instancesdir}/tomcat@"
}

[ -d "${instancesdir}" ] || {
  mkdir -p "${instancesdir}"
}

[ $def_instance -eq 0 ] &&
[ -r "/etc/sysconfig/tomcat@" ] &&
[ ! -r "/etc/sysconfig/tomcat@${instancename}" ] && {
  cat "/etc/sysconfig/tomcat@" |
  sed -e 's%^\(CATALINA_BASE\)=[^ ].*$%\1='"${CATALINA_BASE}"'%g' \
    1>"/etc/sysconfig/tomcat@${instancename}" 2>/dev/null
}

set -u

[ -d "${CATALINA_BASE}" ] ||
mkdir -p "${CATALINA_BASE}" 1>/dev/null 2>&1

cd "${CATALINA_BASE}" && {

  cat <<_EOF_
# Tomcat user and home dir.
TOMCAT_USER=$TOMCAT_USER
TOMCAT_HOME=$TOMCAT_HOME
# Where your tomcat installation lives.
CATALINA_HOME=$CATALINA_HOME
CATALINA_BASE=$CATALINA_BASE

_EOF_

  [ -d "${template_dir}" ] && {
    echo "Expand the template '${template_dir}'."
    ( cd "${template_dir}" &&
      tar -pc . |tar -C "${CATALINA_BASE}" -xvf - )
  }

  for dir in bin conf{,/Catalina/localhost} lib webapps/{deploy,versions}
  do
    [ -d "./${dir}" ] || {
      echo "Make directory '${dir}'."
      mkdir -p "./${dir}"
    }
  done

  chown -R "root:${TOMCAT_USER}" . &&
  find . -type d -exec chmod 2755 {} \; &&
  find . -type f -exec chmod 0644 {} \; &&
  find . -type f -a -name "*.sh" -exec chmod 0755 {} \;

  for dir in conf/Catalina{,/localhost} webapps/{deploy,versions}
  do
    chown "${TOMCAT_USER}:${TOMCAT_USER}" "./$dir" &&
    chmod 2755 "./$dir"
  done

  for file in "${TOMCAT_HOME}"/bin/tc-* "${TOMCAT_HOME}"/bin/tomcat*.rc
  do
    filepath="${file%/*}"
    filename="${file##*/}"
    [ -d "${file}" ] && continue
    [ -e "./${filepath##*/}/${filename}" ] && continue
    echo "Symlinked '${file}' to '${filepath##*/}/${filename}'."
    ln -sf "${file}" "./${filepath##*/}/${filename}"
  done

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

  for file in "${CATALINA_HOME}"/conf/*.*
  do
    filepath="${file%/*}"
    filename="${file##*/}"
    [ -d "${file}" ] && continue
    [ -e "./${filepath##*/}/${filename}" ] && continue
    echo "$file" |grep -E '.*\.bat$' 1>&2 && continue
    echo "Copy '${file}' to '${filepath##*/}/${filename}'."
    cp -f "${file}" "./${filepath##*/}/${filename}" &&
    chown "root:${TOMCAT_USER}" "./${filepath##*/}/${filename}" &&
    chmod 0644 "./${filepath##*/}/${filename}"
  done

  for symlnk in \
    logs:log/${instancename} \
    run:run/${instancename} \
    work:lib/${instancename}/work \
    temp:lib/${instancename}/temp
  do
    symlnk_to="${symlnk%:*}"
    symlnksrc="${TOMCAT_HOME}/var/${symlnk##*:}"
    [ -e "./${symlnk_to}" ] && continue
    [ -d "${symlnksrc}" ] || mkdir -p "${symlnksrc}"
    chown "${TOMCAT_USER}:${TOMCAT_USER}" "${symlnksrc}" &&
    chmod 2755 "${symlnksrc}"
    echo "Symlinked '${symlnksrc}' to '${symlnk_to}'."
    ln -sf "${symlnksrc}" "./${symlnk_to}"
  done

  logrotate_file="/etc/logrotate.d/tomcat"

  [ $def_instance -eq 0 ] && { 
    logrotate_file="${logrotate_file}@${instancename}"
  }

  [ -d "/etc/logrotate.d" ] && {

    cat <<_EOF_
$CATALINA_OUT {
 daily
 rotate 30
 missingok
 copytruncate
 create 0644 $TOMCAT_USER $TOMCAT_USER
}
_EOF_

  } >"${logrotate_file}"

  [ $def_instance -eq 0 ] && [ -r "./bin/setenv.sh" ] && {

    diff "${template_dir}/bin/setenv.sh" ./bin/setenv.sh 1>/dev/null && {

      tmp_setenv_sh="./bin/.setenv.$$"

      cat "./bin/setenv.sh" |
      sed -e 's/^\(#* *| *\)\(INSTANCENAME\)=[^=].*$/\2='"$instancename"'/g' \
          1>"${tmp_setenv_sh}" 2>/dev/null &&
      mv -f "${tmp_setenv_sh}" "./bin/setenv.sh"

    }

  } # [ $def_instance -eq 0 ] && [ -r "./bin/setenv.sh" ]

  [ -r "./conf/server.xml" ] && {

    [ -e "./conf/server.xml.ORIG" ] ||
    cp -pf ./conf/server.xml{,.ORIG}

    cat ./conf/server.xml.ORIG |
    sed -e 's%="8005"%="${catalina.port.shutdown}"%g'  \
        -e 's%="8009"%="${catalina.port.ajp}"%g' \
        -e 's%="8080"%="${catalina.port.http}"%g'  \
        -e 's%="8443"%="${catalina.port.https}"%g' \
        -e 's%\(appBase\)="webapps"%\1="${catalina.webapps.dir}"%g' \
        1>./conf/server.xml && {
      echo "Fixed 'server.xml'."
      diff -u ./conf/server.xml{.ORIG,}
    }

  } # [ -r "./conf/server.xml" ]

} 2>/dev/null |
while read stdoutln
do
  echo "$THIS: $stdoutln"
done

exit 0
