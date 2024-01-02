# functions

# Stdout
__stdout() {
  local _tag="${1:+${1}: }"
  ${AWK} -f <(
cat - <<_EOF_
{
  printf("%s%s\n","${_tag}",\$0);
  fflush();
}
_EOF_
  )
  return 0
}

# Stderr
__stderr() {
  local _tag="${1:-}"
  __stdout "${_tag:+${_tag}: }ERROR" 1>&2
  return 0
}

# Wait
__wait() {
  local cpid="${1:-$!}"
  while :
  do
    ps |${AWK} '{print($1);}' |egrep "${cpid}"
    if [ $? -eq 0 ]
    then sleep 1
    else break
    fi
  done &>/dev/null
  return 0
} &>/dev/null

# end
return 0