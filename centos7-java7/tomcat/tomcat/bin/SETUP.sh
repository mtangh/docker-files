#!/bin/sh
REAL=$(readlink -f $0 2>/dev/null)
THIS="${REAL##*/}"
RDIR="${REAL%/bin/*}"
BDIR="${REAL%/*}"

# catalina.home
CATALINA_HOME="${CATALINA_HOME:-${RDIR}}"

# Load 'setenv.sh' file
for dir in "$CATALINA_BASE" "$CATALINA_HOME" "$RDIR"
do
  [ -n "$dir" ] ||
    continue
  [ -e "${dir}/bin/setenv.sh" ] ||
    continue
  echo "$THIS: '${dir}/bin/setenv.sh' loaded"
  . "${dir}/bin/setenv.sh"
  break
done

# service name
if [ -z "$SERVICENAME" ] &&
   [ -n "$CATALINA_BASE" ]
then
  SERVICENAME="${CATALINA_BASE##*/}"
fi
if [ -z "$SERVICENAME" ] &&
   [ -n "$CATALINA_HOME" ]
then
  SERVICENAME="${CATALINA_HOME##*/}"
fi
if [ -z "$SERVICENAME" ]
then
  SERVICENAME="${RDIR##*/}"
fi

# print env
echo "$THIS: TOMCAT_USER   = $TOMCAT_USER"
echo "$THIS: CATALINA_HOME = $CATALINA_HOME"
echo "$THIS: CATALINA_BASE = $CATALINA_BASE"
echo "$THIS: SERVICENAME   = $SERVICENAME"
echo "$THIS: SUFFIX        = $SUFFIX"
echo "$THIS: SUFFIXDIR     = $SUFFIXDIR"

# TOMCAT_USER home directory
tomcat_home="/var/lib/${TOMCAT_USER}"

# function: Check group
function check_group() {
  awk -F: '{print($1);};' </etc/group   |
  grep "$TOMCAT_USER" 1>/dev/null 2>&1
  return $?
}

# function: Check gtoup
function check_user() {
  awk -F: '{print($1);};' </etc/passwd  |
  grep "$TOMCAT_USER" 1>/dev/null 2>&1
  return $?
}

# function: Add group
function add_group() {
  groupopts="-f"
  type groupadd 1>/dev/null 2>&1        ||
    return 127
  for gid in 91 92 93 94 95 96 97 98 99
  do
    awk -F: '{print($3);};' </etc/group |
    grep $gid 1>/dev/null 2>&1          &&
      continue
    groupopts="${groupopts} -g $gid"
    break
  done
  groupadd ${groupopts} "$TOMCAT_USER" 1>/dev/null 2>&1
  return $?
}

# function: Add user
function add_user() {
  useropts="-g ${TOMCAT_USER} -c Tomcat -d ${tomcat_home} -m"
  type useradd 1>/dev/null 2>&1              ||
    return 127
  for uid in 91 92 93 94 95 96 97 98 99
   do
    awk -F: '{print($3);};' </etc/passwd     |
    grep $uid 1>/dev/null 2>&1               &&
      continue
    useropts="${useropts} -u $uid"
    break
  done
  useradd ${useropts} "$TOMCAT_USER" 1>/dev/null 2>&1   &&
  mktemp -u XXXXXXXX 2>/dev/null                        |
   passwd --stdin "$TOMCAT_USER" 1>/dev/null 2>&1
  return $?
}

# function: Change group
function chg_group() {
  id -a $TOMCAT_USER                          1>/dev/null 2>&1  |
  grep -E '[ ]+groups=.*('"$TOMCAT_USER"').*' 1>/dev/null 2>&1  ||
    usermod -G "${TOMCAT_USER}" "${TOMCAT_USER}"
  return $?
}

# function: Change home
function chg_home() {
  cat /etc/passwd                           |
  awk -F: '/^tomcat:/{print($6);}'          |
  grep "${tomcat_home}" 1>/dev/null 2>&1    ||
    usermod -d "${tomcat_home}" "${TOMCAT_USER}"
  return $?
}

# Linked from CATALINA_HOME/bin/*.sh
if [ "${CATALINA_HOME}" != "${CATALINA_BASE}" ]
then
  for tomcat_sh in "${CATALINA_HOME}"/bin/*.sh
  do
    if [ ! -e "$tomcat_sh" ]
    then
      continue
    fi
    if [ ! -e "${CATALINA_BASE}/bin/${tomcat_sh##*/}" ]
    then
      ln -sf "$tomcat_sh" "${CATALINA_BASE}/bin/" &&
      echo "$THIS: Linked: '$tomcat_sh'"
    fi
  done 2>/dev/null
fi

# Change mode +x
for dir in "$CATALINA_BASE" "$CATALINA_HOME"
do
  if [ -d "$dir/bin" ]
  then
    chmod -R a+x "$dir"/bin/*.sh
  fi
  if [ -d "$dir/tools" ]
  then
    chmod -R a+x "$dir"/tools/*.sh
  fi
done

# TOMCAT_USER Group
if ! check_group
then
  add_group ; _ret=$?
  if [ $_ret -eq 0 ]
  then
    echo "$THIS: TOMCAT_USER: group '$TOMCAT_USER' added"
  elif [ $_ret -ne 127 ]
  then
    echo "$THIS: TOMCAT_USER: group '$TOMCAT_USER' added NG"
  else
    echo "$THIS: TOMCAT_USER: command not found 'groupadd'"
  fi
else
  echo "$THIS: TOMCAT_USER: group '$TOMCAT_USER' already exists"
fi

# User
if ! check_user
then
  echo "$THIS: TOMCAT_USER '$TOMCAT_USER' not exist"
  # useradd
  if check_group
  then
    add_user ; _ret=$?
    if [ $_ret -eq 0 ]
    then
      echo "$THIS: TOMCAT_USER: user '$TOMCAT_USER' added"
    elif [ $_ret -ne 127 ]
    then
      echo "$THIS: TOMCAT_USER: user '$TOMCAT_USER' added NG"
    else
      echo "$THIS: TOMCAT_USER: command not found 'useradd'"
    fi
  fi
else
  echo "$THIS: TOMCAT_USER '$TOMCAT_USER' already exist"
  check_group &&
    chg_group
  [ -d "$tomcat_home" ] ||
    mkdir -p "$tomcat_home"
  [ -d "$tomcat_home" ] &&
    chg_home
fi

# Create link to /etc/init.d
if [ -n "$SERVICENAME" ]
then
  for initsh in \
  "$CATALINA_BASE/bin/${SERVICENAME}.sh" \
  "$CATALINA_HOME/bin/${SERVICENAME}.sh" \
  "$CATALINA_BASE/bin/JciTomcat-${SERVICENAME}.sh" \
  "$CATALINA_HOME/bin/JciTomcat-${SERVICENAME}.sh" \
  "$CATALINA_BASE/bin/JciTomcat.sh" \
  "$CATALINA_HOME/bin/JciTomcat.sh" ;
  do
    [ -x "$initsh" ] ||
      continue
    echo "$THIS: '$initsh' found"
    (
      for dir in etc/rc.d/init.d /etc/init.d
      do
        [ -d "$dir" ] ||
          continue
        [ -e "$dir/$SERVICENAME" ] &&
          continue
        echo -n "$THIS: create link '$SERVICENAME' to $dir ... "
        cd "$dir" &&
        ln -sf "$initsh" $SERVICENAME &&
        if [ $? -eq 0 ]
        then
          echo "OK"
        else
          echo "NG"
        fi
        break
      done
    )
    break
  done
fi

# Addon setup scripts
if [ -d "$BDIR/SETUP.d" ]
then
  for scr in $(ls -1 $BDIR/SETUP.d/*.sh 2>/dev/null)
  do
    [ -x "$BDIR/SETUP.d/$scr" ] ||
      continue
    echo "$THIS: Execute script '$scr'"
    . "$BDIR/SETUP.d/$scr"
  done
fi

# Register service
if [ -x /sbin/chkconfig ]
then

  # Add service
  if ! /sbin/chkconfig --list |grep "$SERVICENAME" 1>/dev/null 2>&1
  then
    echo -n "$THIS: Adding service '$SERVICENAME' ... "
    /sbin/chkconfig --add $SERVICENAME 1>/dev/null 2>&1
    if [ $? -eq 0 ]
    then
      echo "OK"
    else
      echo "NG"
    fi
  else
    echo "$THIS: Service '$SERVICENAME' already exists."
  fi

  # Register startup
  echo -n "$THIS: Registering $SERVICENAME on startup at init level 3 and 5 ... "
  /sbin/chkconfig --level 35 "$SERVICENAME" on 1>/dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo "OK"
  else
    echo "NG"
  fi

else
  echo "chkconfig not found"
fi

# Remove initialized mark file
if [ -e "${CATALINA_BASE}/.initialized" ]
then
  rm -f "${CATALINA_BASE}/.initialized"
fi

# *eof*
exit 0
