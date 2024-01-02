#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

work_dir=$(pwd)

[ -x "$(type -P httpd)" ] || {
  echo "command 'httpd' not found." 1>&2
  exit 1
}

: "Remove 'welcome'." && {

  mv -fv /usr/share/httpd/{noindex/images,icons}/poweredby.png || :
  rm -fv "/etc/httpd/conf.d/welcome.conf" || :
  rm -rfv "/usr/share/httpd/noindex"/* || :

} &&
: "Update httpd.conf" && {

  httpdcnf="/etc/httpd/conf/httpd.conf"

  : "Backup origin" && {

    [ -e "${httpdcnf}.ORIG" ] ||
    cp -pf "${httpdcnf}"{,.ORIG}
  
  } &&
  if [ -s "./httpd.conf" ]
  then
    cat "./httpd.conf" 1>"${httpdcnf}"
  else
    cat "${httpdcnf}.ORIG" |
    sed -r \
      -e 's/^[#[:space:]]*(ServerAdmin)[[:space:]]+.*$/\1 admin@localhost/gi' \
      -e 's/^[#[:space:]]*(ServerTokens)[[:space:]]+.*$/\1 Prod/gi' \
      -e 's/^[#[:space:]]*(ServerSignature)[[:space:]]+.*$/\1 Off/gi' \
      -e 's/^[#[:space:]]*(AddDefaultCharset)[[:space:]]+.*$/\1 UTF-8/gi' \
      1>"${httpdcnf}"
  fi &&
  /usr/sbin/httpd -t

} &&
: "Done.";

exit $?