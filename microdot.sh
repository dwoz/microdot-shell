#!/bin/bash


function microdot {

  MD_GIT_BIN=${MD_GIT_BIN:=/usr/bin/git}
  MD_GIT_HOME=${MD_GIT_HOME:="$HOME"}
  MD_GIT_DIR=${MD_GIT_DIR:-.dotgit}
  OVERRIDE_UNTRACKED=0
  CAN_OVERRIDE_UNTRACKED=0
  STATUS_CHECK=0
  function requote() {
      local res=""
      for x in "${@}" ; do
          # try to figure out if quoting was required for the $x:
          grep -q "[[:space:]]" <<< "$x" && res="${res} '${x}'" || res="${res} ${x}"
      done
      # remove first space and print:
      sed -e 's/^ //' <<< "${res}"
  }
  ARGS=$(requote "${@}")

  while [[ $# -gt 0 ]]
  do
    arg="$1"

    case $arg in
      --md-check)
        STATUS_CHECK=1
      ;;
      status|commit)
        CAN_OVERRIDE_UNTRACKED=1
      ;;
      -u*|--untracked-files=*)
        OVERRIDE_UNTRACKED=1
      ;;
      *)
        # no-op
      ;;
    esac
    shift
  done
  GITCMD=(
    "${MD_GIT_BIN}"
    "--git-dir=${MD_GIT_HOME}/${MD_GIT_DIR}/"
    "--work-tree=${MD_GIT_HOME}"
  )
  GITCMD="${GITCMD[@]}"
  if [ $STATUS_CHECK -eq 1 ]; then
      if ! $($GITCMD remote update 2>&1 > /dev/null); then
          return 1;
      fi
      UPSTREAM=${1:-'@{u}'}
      LOCAL=$($GITCMD rev-parse @)
      REMOTE=$($GITCMD rev-parse "$UPSTREAM")
      BASE=$($GITCMD merge-base @ "$UPSTREAM")
      if [ $LOCAL = $REMOTE ]; then
          echo "microdot data is up-to-date"
      elif [ $LOCAL = $BASE ]; then
          echo "microdot data as upstream changes"
      elif [ $REMOTE = $BASE ]; then
          echo "microdot data has local changes"
      else
          echo "microdot data has both local and upstream changes"
      fi
      return 0

  fi
  echo "microdot: ${GITCMD} ${ARGS}"
  if [ $OVERRIDE_UNTRACKED -eq 0 ] && [ $CAN_OVERRIDE_UNTRACKED -eq 1 ]; then
      # echo "Override: $ARGS"
      bash -c "${GITCMD} ${ARGS} -uno"
  else
      # echo "No override: $ARGS"
      bash -c "${GITCMD} ${ARGS}"
  fi

}
