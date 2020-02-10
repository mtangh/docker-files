#!/bin/bash -ux

rootpswd="${ROOTPSWD:-}"

: "Set root password" && {

  if [ -n "${rootpswd:-}" ]
  then

    echo "${rootpswd}" |
    passwd --stdin root &&
    passwd -u root &&
    passwd -S root

  fi || exit 1

} &&
[ $? -eq 0 ]

