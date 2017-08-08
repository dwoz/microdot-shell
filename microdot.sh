#!/bin/bash
#
# microdot is a thin wrapper around git in the form of a bash function. The
# purpose is to provide dot file history, backup and syncinc to multiple
# places. Git already does a great job of stroing history, backing things up
# and syncing changes to multiple places. So microdot leverages the power of
# git. The mocrodot function provides a simplified workflow to managing a set
# of files in your home directory under git without turning your entire home
# directory into a git repository.
#

function microdot {

  # Anything prefixed with MD can be overridden with an environment variable.
  MD_GIT_BIN=${MD_GIT_BIN:=/usr/bin/git}
  MD_GIT_HOME=${MD_GIT_HOME:="$HOME"}
  MD_GIT_DIR=${MD_GIT_DIR:-.dotgit}

  OVERRIDE_UNTRACKED=0
  CAN_OVERRIDE_UNTRACKED=0
  CLONE_CMD=0
  STATUS_CHECK=0

  # Quoted arguments like the following can cause problems: 
  #   md commit .bashrc -m 'My commit  message'
  # This requote function aims to re-construct the arguments with
  # quotes so that we can pass the the quoted string as a single argument when
  # they are prozied to the git command.
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
      clone)
        CLONE_CMD=1
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

  if [ $CLONE_CMD -eq 1 ]; then
      GITCMD=(
        "${MD_GIT_BIN}"
        "--separate-git-dir=${MD_GIT_HOME}/${MD_GIT_DIR}"
      )
  else
      GITCMD=(
        "${MD_GIT_BIN}"
        "--git-dir=${MD_GIT_HOME}/${MD_GIT_DIR}"
        "--work-tree=${MD_GIT_HOME}"
      )
  fi
  GITCMD="${GITCMD[@]}"

  if [ $STATUS_CHECK -eq 1 ]; then

      if [ ! $($GITCMD remote update 2>&1 > /dev/null) ]; then
          return 1;
      fi
      #UPSTREAM=${1:-'@{u}'}
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
      return 0;

  fi

  echo "microdot: ${GITCMD} ${ARGS}"

  if [ $CLONE_CMD -eq 1 ]; then
     bash -c "${GITCMD} ${ARGS} /tmp/.mdtmp";
     rm -rf ./tmp/mdtmp;
     return 0;
  fi

  if [ $OVERRIDE_UNTRACKED -eq 0 ] && [ $CAN_OVERRIDE_UNTRACKED -eq 1 ]; then
      # echo "Override: $ARGS"
      bash -c "${GITCMD} ${ARGS} -uno"
  else
      # echo "No override: $ARGS"
      bash -c "${GITCMD} ${ARGS}"
  fi

}
