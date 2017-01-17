# _docker-functions.sh
DOCKERFUNC_SRC="${BASH_SOURCE##*/}"
DOCKERFUNC_DIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

# Load the functins
if [ -n "${DOCKERFUNC_DIR}" -a -d "${DOCKERFUNC_DIR}/functions" ]
then
  for func in "${DOCKERFUNC_DIR}"/functions/*
  do
    . "${func}" 
  done 2>/dev/null
fi

# echo start
__echo_start() {
  echo "{{{ START - $(date +'%Y%m%dT%H%M%S')"
  [ -n "$1" ] &&
  echo "COMMAND=[$@]"
  return 0
}

# echo end
__echo_end() {
  _exit_st=$1
  if [ $_exit_st -eq 0 ]
  then
    echo "}}} END - $(date +'%Y%m%dT%H%M%S')"
  else
    echo "}}} ERROR OCCURED - ret($_exit_st)."
    exit $_exit_st
  fi
  return 0
}

# Section
__section() {
  printf "$THIS: "
  for i in {1..68};do printf '-';done;echo
  return 0
}

# vim: set ff=unix ts=2 sw=2 sts=2 et : This line is VIM modeline
return 0
