function _buildenv_git_branch() {
  local prompt=""
  local ref=""
  ref=$(git symbolic-ref HEAD 2>/dev/null)
  if [[ $? -eq 0 ]];then
    echo -n "(${ref#refs/heads/})"
  fi
}

function _buildenv_git_status() {
#FIXME: This needs to be async so as to not slow down "cd kdelibs/"
  return 0
  local ref=""
  ref=$(git symbolic-ref HEAD 2>/dev/null)
  if [[ $? -eq 0 ]];then
    local _changes=$(git status --porcelain | grep -E "^.[MD]" 2>/dev/null)
    if [[ $? -eq 0 ]];then
      echo -n "!"
    fi
  fi
}

export PS1="\[\033[1;32m\]\$(_buildenv_git_branch)\[\033[1;31m\]\$(_buildenv_git_status)\[\033[0m\]$PS1"
