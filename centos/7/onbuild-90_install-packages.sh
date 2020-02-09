#!/bin/bash -ux

packages="${PACKAGES:-}"

: "ONBUILD: Install packages" && {

  if [ -n "${packages:-}" ]
  then

    yum -v -y update &&
    yum -v -y install ${packages} &&
    yum -v -y clean all;

  fi || exit 1

  rm -rf /var/cache/yum/*

} &&
[ $? -eq 0 ]

