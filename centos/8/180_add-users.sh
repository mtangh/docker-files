#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

: "SetUp default user" && {

  passwdfile="/etc/passwd"
  group_file="/etc/group"

  set +x &&
  while read row_data
  do

    dockeruser=""
    docker_uid=""
    docker_grp=""
    docker_gid=""
    dockerdesc=""
    dockerhome=""
    dockersudo=""
    dockerpswd=""

    [ -n "${row_data:-}" ] && {
      eval $(
echo "${row_data}" |
sed -re 's/#.*$//g' |
awk -F: -f <( cat - <<_EOS_
\$0 ~ /^[[:space:]]*[^[:space:]]+/ {
  printf( "%s='%s';\n", "dockeruser", \$1 );
  printf( "%s='%s';\n", "docker_uid", \$2 );
  printf( "%s='%s';\n", "docker_grp", \$3 );
  printf( "%s='%s';\n", "docker_gid", \$4 );
  printf( "%s='%s';\n", "dockerdesc", \$5 );
  printf( "%s='%s';\n", "dockerhome", \$6 );
  printf( "%s='%s';\n", "docker_shl", \$7 );
  printf( "%s='%s';\n", "dockersudo", \$8 );
  printf( "%s='%s';\n", "dockerpswd", \$9 );
}
_EOS_
)
      )
      [ -n "${dockeruser:-}" -o \
        -n "${docker_grp:-}" ]
    } || continue

    echo "dockeruser=[${dockeruser:-}]"
    echo "docker_uid=[${docker_uid:-}]"
    echo "docker_grp=[${docker_grp:-}]"
    echo "docker_gid=[${docker_gid:-}]"
    echo "dockerdesc=[${dockerdesc:-}]"
    echo "dockerhome=[${dockerhome:-}]"
    echo "dockersudo=[${dockersudo:-}]"
    echo "dockerpswd=[${dockerpswd:+********}]"

    set -x

    # Group
    if [ -n "${docker_grp}" ]
    then

      g_temp_gid=$(
cat "${group_file}" |
awk -F: -f <( cat - <<_EOS_
\$1 ~ /^${docker_grp}\$/ {
  print(\$2);
}
_EOS_
)
      )

      if [ -z "${g_temp_gid:-}" ]
      then
        groupadd ${docker_gid:+-g ${docker_gid} }"${docker_grp}" ||
          exit 1
      else
        if [ "${docker_gid:-${g_temp_gid}}" != "${g_temp_gid}" ]
        then
          groupmod -g "${docker_gid}" "${docker_grp}" ||
            exit 1
        fi
      fi

      docker_gid=$(
cat "${group_file}" |
awk -F: -f <( cat - <<_EOS_
\$1 ~ /^${docker_grp}\$/ {
  print(\$3);
}
_EOS_
)
      )

    elif [ -n "${docker_gid}" ]
    then

      docker_grp=$(
cat "${group_file}" |
awk -F: -f <( cat - <<_EOS_
\$2 ~ /^${docker_gid}\$/ {
  print(\$1);
}
_EOS_
)
      )

    fi # [ -n "${docker_grp}" ]

    # User
    if [ -n "${dockeruser}" ]
    then

      u_temp_uid=$(
cat "${passwdfile}" |
awk -F: -f <( cat - <<_EOS_
\$1 ~ /^${dockeruser}\$/ {
  print(\$3);
}
_EOS_
)
      )

      if [ -z "${u_temp_uid:-}" ]
      then
        useradd -m \
          ${docker_uid:+-u ${docker_uid}} \
          ${docker_gid:+-g ${docker_gid}} \
          ${dockerdesc:+-c ${dockerdesc}} \
          ${dockerhome:+-d ${dockerhome}} \
          ${docker_shl:+-s ${docker_shl}} \
          "${dockeruser}" ||
          exit 1
      else
        if [ "${docker_uid:-${u_temp_uid}}" != "${u_temp_uid}" ] ||
           [ -n "${docker_gid}" -o \
             -n "${dockerdesc}" -o \
             -n "${dockerhome}" -o \
             -n "${docker_shl}" ]
        then
          usermod \
            ${docker_uid:+-u ${docker_uid}} \
            ${docker_gid:+-g ${docker_gid}} \
            ${dockerdesc:+-c ${dockerdesc}} \
            ${dockerhome:+-d ${dockerhome}} \
            ${docker_shl:+-s ${docker_shl}} \
            "${dockeruser}" ||
            exit 1
        fi
      fi # if [ -z "${u_temp_uid:-}" ]

      docker_uid=$(
cat "${passwdfile}" |
awk -F: -f <( cat - <<_EOS_
\$1 ~ /^${dockeruser}\$/ {
  print(\$2);
}
_EOS_
)
      )

      # SUDO
      if [ -n "${dockersudo:-}" ]
      then

        new_groups=""

        case "${dockersudo}" in
        [Nn][Oo])
          new_groups=$(
            echo $(groups "${dockeruser}" |
            awk -F: '{print($2);}' |
            sed -re 's/wheel//g') |
            sed -re 's/[[:space:]]+/,/g'; )
          ;;
        *)
          new_groups=$(
            echo $(groups "${dockeruser}" |
            awk -F: '{print($2,"wheel");}') |
            sed -re 's/[[:space:]]+/,/g'; )
          ;;
        esac

        usermod -G "${new_groups}" "${dockeruser}" ||
          exit 1

      else : "noop"
      fi # if [ -n "${dockersudo:-}" ]

      set +x

      # Password
      if [ -z "${dockerpswd:-}" ]
      then
        echo "Password has not been set, generate a password." &&
        if [ -x "$(type -P mktemp)" ]
        then
          dockerpswd=$(mktemp -u XXXXXXXX 2>/dev/null)
        else
          dockerpswd=$(dd status=none if=/dev/urandom count=50 |md5sum)
          dockerpswd="${dockerpswd%% *}"
        fi
      fi &&
      if [ -x "$(type -P passwd)" ]
      then
        echo "Set user ${dockeruser}'s password using the 'passwd' command." &&
        echo "${dockerpswd}" |
        passwd --stdin "${dockeruser}" &&
        passwd -S "${dockeruser}"
      else
        echo "Set user ${dockeruser}'s password using the 'chpasswd' command." &&
        echo "${dockeruser}:${dockerpswd}" |
        chpasswd
      fi

    fi # if [ -n "${dockeruser}" ]

  done < <(
    if [ -s "${DOCKER_USERS:-}" ]
    then cat "${DOCKER_USERS}"
    elif [ -n "${DOCKER_USERS:-}" ]
    then echo "${DOCKER_USERS}"
    else : "noop"
    fi 2>/dev/null
    ) &&
  set -x

} &&
[ $? -eq 0 ]

exit $?
