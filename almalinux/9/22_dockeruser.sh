#!/bin/bash -ux

dockeruser="${DOCKERUSER:-}"
docker_uid="${DOCKER_UID:-}"
docker_grp="${DOCKER_GRP:-}"
docker_gid="${DOCKER_GID:-}"
dockerpass="${DOCKERPASS:-}"
dockersudo="${DOCKERSUDO:-}"

: "SetUp default user" && {

  if [ -n "${dockeruser:-}" -o \
       -n "${docker_uid:-}" -o \
       -n "${docker_grp:-}" -o \
       -n "${docker_gid:-}" -o \
       -n "${dockerpass:-}" -o \
       -n "${dockersudo:-}" ]
  then

    [ -n "${docker_uid:-}" ] || docker_uid="500"
    [ -n "${docker_grp:-}" ] || docker_grp="${dockeruser}"
    [ -n "${docker_gid:-}" ] || docker_gid="${docker_uid}"
    [ -n "${dockerpass:-}" ] || dockerpass=$(dd "if=/dev/urandom" count=50 |md5sum)

    echo "${docker_uid:-0}" |egrep '^[0-9]+$' 1>/dev/null 2>&1 || {
      echo "Illegal parameter: 'docker_uid'." 1>&2
      exit 2
    } || :

    echo "${docker_gid:-0}" |egrep '^[0-9]+$' 1>/dev/null 2>&1 || {
      echo "Illegal parameter: 'docker_gid'." 1>&2
      exit 2
    } || :

    passwdfile="/etc/passwd"
    group_file="/etc/group"

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

    groupadd -g "${docker_gid}" "${docker_grp}" &&
    useradd -u "${docker_uid}" -g "${docker_grp}" -m "${dockeruser}" &&
    echo "${dockerpass}" |passwd --stdin "${dockeruser}" ||
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
