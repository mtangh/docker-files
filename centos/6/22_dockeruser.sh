#!/bin/bash -ux

dockeruser="${DOCKERUSER:-}"
dockerpswd="${DOCKERPSWD:-}"

docker_uid="${DOCKER_UID:-}"
docker_grp="${DOCKER_GRP:-}"
docker_gid="${DOCKER_GID:-}"

dockername="${DOCKER_ACCOUNTNAME:-}"
dockergrps="${DOCKER_GROUPS_LIST:-}"
dockerhome="${DOCKER_USERHOMEDIR:-}"
docker_lsh="${DOCKER_LOGIN_SHELL:-}"

dockersudo="${DOCKER_ENABLE_SUDO:-}"

: "SetUp default user" && {

  if [ -n "${dockeruser:-}" -o \
       -n "${docker_uid:-}" -o \
       -n "${docker_grp:-}" -o \
       -n "${docker_gid:-}" -o \
       -n "${dockergrps:-}" -o \
       -n "${dockername:-}" -o \
       -n "${dockerhome:-}" -o \
       -n "${docker_lsh:-}" -o \
       -n "${dockersudo:-}" ]
  then

    passwdfile="/etc/passwd"
    group_file="/etc/group"

    [ -n "${dockeruser:-}" ] || dockeruser="dockeruser"
    [ -n "${dockerpswd:-}" ] || dockerpswd=$(dd "if=/dev/urandom" count=50 |md5sum)

    [ -n "${docker_uid:-}" ] || docker_uid="500"
    [ -n "${docker_grp:-}" ] || docker_grp="${dockeruser}"
    [ -n "${docker_gid:-}" ] || docker_gid="${docker_uid}"

    [ -n "${dockername:-}" ] || dockername="${dockeruser}"
    [ -n "${dockergrps:-}" ] || dockergrps="wheel"
    [ -n "${dockerhome:-}" ] || dockerhome="/home/${dockeruser}"
    [ -n "${docker_lsh:-}" ] || docker_lsh="/bin/bash"

    echo "${docker_uid:-0}" |egrep '^[0-9]+$' 1>/dev/null 2>&1 || {
      echo "Illegal parameter: 'DOCKER_UID' ["${docker_uid:-0}"]." 1>&2
      exit 2
    } || :

    echo "${docker_gid:-0}" |egrep '^[0-9]+$' 1>/dev/null 2>&1 || {
      echo "Illegal parameter: 'DOCKER_GID' [${docker_gid:-0}]." 1>&2
      exit 2
    } || :

    [ -x "${docker_lsh:-}" ] || {
      echo "Illegal parameter: 'DOCKER_LOGIN_SHELL' [${docker_lsh:-}]." 1>&2
      exit 2
    }

    ( IFS=","
      for grp_name in $(echo "${dockergrps:-}")
      do
        [ "${dockeruser}" == "${grp_name:-}" ] || {
          egrep "^${grp_name}:" "${group_file}" ||
          exit 2
        } 1>/dev/null 2>&1
      done
    ) || {
      echo "Illegal parameter: 'DOCKER_GROUPS_LIST' [${dockergrps:-}]." 1>&2
      exit 2
    }

    egrep "^dockeruser:" "${passwdfile}" && {
      userdel -fr "dockeruser"
    } || :
    egrep "^${dockeruser}:" "${passwdfile}" && {
      userdel -fr "${dockeruser}"
    } || :

    egrep "^dockeruser:" "${group_file}" && {
      groupdel "dockeruser"
    } || :
    egrep "^${docker_grp}:" "${group_file}" && {
      groupdel "${docker_grp}"
    } || :

    groupadd \
      -g "${docker_gid}" "${docker_grp}" &&
    useradd \
      -u "${docker_uid}" -g "${docker_grp}" -G "${dockergrps}" \
      -d "${dockerhome}" -c "${dockername}" -s "${docker_lsh}" \
      -m "${dockeruser}" &&
    echo "${dockerpswd}" |passwd --stdin "${dockeruser}" ||
    exit 1

    sudoerfile="/etc/sudoers"
    insertline="${dockeruser}\tALL=(ALL)\tNOPASSWD: ALL\t# For docker user"

    if [ -s "${sudoerfile}" ]
    then

      sed -ri \
      '/^(dockeruser|'"${dockeruser}"')[[:space:]]+/d' "${sudoerfile}" ||
      exit 1

      case "${dockersudo:-YES}" in
      [Nn][Oo])
        ;;
      *)
        sed -ri \
        '/^root[ \t]*ALL.*$/a '"${insertline}" "${sudoerfile}" ||
        exit 1
        ;;
      esac

    else : "noop"
    fi

  else : "noop"
  fi

} &&
[ $? -eq 0 ]

exit $?
