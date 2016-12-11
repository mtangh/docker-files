# _docker-functions.sh
THIS=${THIS:-DOCKER-BIN}

# echo start
__echo_start() {
  echo "START - $(date +'%Y%m%dT%H%M%S')"
  [ -n "$1" ] &&
  echo "COMMAND=[$@]"
  return 0
}

# echo end
__echo_end() {
  _exit_st=$1
  if [ $_exit_st -eq 0 ]
  then
    echo "END - $(date +'%Y%m%dT%H%M%S')"
  else
    echo "ERROR OCCURED - ret($_exit_st)."
    exit $_exit_st
  fi
  return 0
}

# output filter
__outfilter() {
  __prefix="$THIS: "$([ -n "$1" ] && echo "$1: ")
  while read stdoutln
  do
    echo "${__prefix}${stdoutln}"
  done
  return 0
}

# Separator
__separator() {
  printf "$THIS: "
  for i in {1..68};do printf '-';done;echo
  return 0
}

# end
return 0
