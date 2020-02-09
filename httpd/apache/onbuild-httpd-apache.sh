#!/bin/bash -ux

package_list="./onbuild-httpd-apache.lst"

if [ -n "${package_list:-}" -a -s "${package_list:-}" ]
then
  packages=$(echo $(cat "${package_list}"))
else
  packages="httpd mod_ssl"
  echo "The Apache Package List is empty, using default: '${packages}''." 1>&2
fi;

: "ONUILD: Install Apache Packages" && {

  yum -v -y update &&
  yum -v -y install ${packages} &&
  yum -v -y clean all &&
  echo

} &&
: "ONUILD: Update httpd.conf" && {

  httpdcnf="/etc/httpd/conf/httpd.conf"

  : && {
    [ -e "${httpdcnf}.ORIG" ] ||
    cp -pf "${httpdcnf}"{,.ORIG}
  } &&
  if [ -e "./httpd.conf" -a -s "./httpd.conf" ]
  then
    cat "./httpd.conf" 1>"${httpdcnf}"
  else
    cat "${httpdcnf}.ORIG" |
    sed -r \
      -e 's#^(ServerAdmin)[ ][ ]*.*$#\1 admin@localhost#g' \
      -e 's#^(ServerTokens)[ ][ ]*.*$#\1 Prod#g' \
      -e 's#^(ServerSignature)[ ][ ]*.*$#\1 Off#g' \
      1>"${httpdcnf}" &&
    echo
  fi &&
  /usr/sbin/httpd -t

} &&
: "Enable httpd service." && {

  systemctl enable httpd

} &&
[ $? -eq 0 ]
