source $BUILDENV_HOME/lib/buildenv/hooks.sh

function _buildenv_background_update_check() {
  if [ ! -f $BUILDENV_HOME/.update-available ];then
    _buildenv_debug "Starting background update check"
    if _buildenv_update_available;then
      _buildenv_debug "Update available!"
      touch $BUILDENV_HOME/.update-available
    else
      _buildenv_debug "No update available."
    fi
  fi
}

function _buildenv_update_available() {
  GIT_SSH="$BUILDENV_HOME/ssh-update-wrapper.sh" git --git-dir=$BUILDENV_HOME/.git/ remote update origin 2>/dev/null > /dev/null
  local _len=$(git --git-dir=$BUILDENV_HOME/.git/ log master..origin/master | wc -l)
  _buildenv_hook update-check
  if [ $_len -gt 0 ];then
    return 0
  fi
  return 1
}

function _buildenv_apply_update() {
  git --git-dir=$BUILDENV_HOME/.git/ checkout master
  git --git-dir=$BUILDENV_HOME/.git/ rebase origin/master
  git --git-dir=$BUILDENV_HOME/.git/ submodule init
  git --git-dir=$BUILDENV_HOME/.git/ submodule update
  _buildenv_hook update-applied
  local _ret=$?
  if [ $_ret -eq 0 ];then
    return 0
  fi
  return 1
}
