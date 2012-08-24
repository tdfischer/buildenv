source $BUILDENV_HOME/lib/load.sh

_buildenv_lib_include buildenv/fs.sh
_buildenv_lib_include buildenv/debug.sh

function _buildenv_is_active() {
  if [ -z "$BUILDENV_MASTER" ];then
    echo "Must be run within a buildenv."
    return 1
  fi
  return 0
}

function _buildenv_is_loaded() {
  if [[ "$BUILDENV_LOADED" != "${BUILDENV_LOADED/ $1 /}" ]];then
    return 0
  fi
  return 1
}

function _buildenv_declare_dependency() {
  _buildenv_load $@
}

function _buildenv_load() {
  if [ -z "$1" ];then
    echo "Usage: _buildenv_load package-name"
    return
  fi
  local _envname=$1
  if _buildenv_is_loaded $_envname;then
    return
  fi
  export BUILDENV_PATH=${BUILDENV_PREFIX}/$_envname
  _buildenv_pkg_set PATH $_envname "$BUILDENV_PATH"
  export BUILDENV_LOADED=" $_envname$BUILDENV_LOADED"
  _buildenv_source_file "${BUILDENV_HOME}/environments/$_envname.sh"
  _buildenv_set PATH "$BUILDENV_PATH/bin:$PATH"
  _buildenv_set LD_LIBRARY_PREFIX "$BUILDENV_PATH/lib/:$LD_LIBRARY_PREFIX"
  echo "Loaded $_envname environment."
  _buildenv_hook buildenv-loaded
}

function _buildenv_unload() {
  if [ -z "$1" ];then
    echo "Usage: _buildenv_unload package-name"
    return
  fi
  _buildenv_env_hook "_teardown" $_envname
  BUILDENV_LOADED=${BUILDENV_LOADED/ $1 / }
  _buildenv_hook buildenv-changed
}

function _buildenv_autodetect() {
  _buildenv_auto_scm_url=$(git config --local --get remote.origin.url)
  _buildenv_auto_scm="git"
  if [ -n "$_buildenv_auto_git_url" ];then
    _buildenv_auto_name=$(basename "${_buildenv_git_url#*:}" .git)
    return 0
  else
    _buildenv_auto_name=$(basename `pwd`)
  fi
}

function _buildenv_load_defaults() {
  local _parent=$(readlink /proc/$PPID/exe)
  _parent=${_parent##*/bin/}
  _buildenv_load_config $USER
  if [ $? -gt 0 ];then
    _buildenv_load_config _default
  fi
#  _buildenv_load_config $_parent
#  _buildenv_load_config $TERM
#  _buildenv_load_config $DESKTOP_SESSION
#  local _host=$HOSTNAME
#  while [ "${_host}" != "${_host/./}" ];do
#    _buildenv_load_config $_host
#    _host=${_host#*.}
#  done
}

function _buildenv_load_config() {
  local _config="$BUILDENV_HOME/config/$1.sh"
  local _ret=1
  export BUILDENV_OLD_CONFIG=${BUILDENV_CONFIG}
  export BUILDENV_CONFIG=$1
  _buildenv_debug "Loading config from $_config"
  if _buildenv_source_file "$_config";then
    _ret=0
  fi
  _config="~/.local/share/buildenv/config/$1.sh"
  _buildenv_debug "Loading user config from $_config"
  if _buildenv_source_file "$_config";then
    _ret=0
  fi
  _buildenv_hook load-config
  return $_ret
}

