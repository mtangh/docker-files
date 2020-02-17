#!/bin/bash -ux

: "Install RPM packages" && {

  packages="${RPM_PACKAGES:-}"

  if [ -z "${packages}" -a -s "./packages.txt" ]
  then
    packages=$(eval echo $(cat "./packages.txt"))
  fi || :

  if [ -n "${packages}" ]
  then

    dnf -v -y update &&
    dnf -v -y install ${packages}

  else :
  fi || exit 1

  [ -n "${packages}" ] && {
    dnf -v -y clean all &&
    rm -rf /var/cache/dnf/*
  } || :

} &&
[ $? -eq 0 ]

exit $?
