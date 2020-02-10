#!/bin/bash -ux

packages="${PACKAGES:-}"

: "Install packages" && {

  if [ -n "${packages:-}" ]
  then

    yum -v -y update &&
    yum -v -y install ${packages}

  fi || exit 1

  yum -v -y clean all;
  rm -rf /var/cache/yum/* || :

} &&
[ $? -eq 0 ]

