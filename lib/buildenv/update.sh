source $BUILDENV_HOME/lib/buildenv/hooks.sh

function _buildenv_background_update_check() {
  if [ ! -f $BUILDENV_HOME/.update-available ];then
    _buildenv_debug "Starting background update check"
    _buildenv_update_check
    if [ $? -eq 0 ];then
      touch $BUILDENV_HOME/.update-available
    fi
  fi
}

function _buildenv_update_check() {
  _buildenv_debug "Checking for update..."
  GIT_SSH="$BUILDENV_HOME/ssh-update-wrapper.sh" git --git-dir=$BUILDENV_HOME/.git/ remote update origin
  local _len=$(git --git-dir=$BUILDENV_HOME/.git/ log master..origin/master | wc -l)
  _buildenv_hook update-check
  if [ $_len -gt 0 ];then
    _buildenv_debug "Update available!"
    return 0
  fi
  _buildenv_debug "No update available."
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
    rm $BUILDENV_HOME/.update-available
    return 0
  fi
  return 1
}
