# Runs a buildenv hook.
# Usage:
# _buildenv_hook hookname
# OR:
# _buildenv_hook hookname environment
# First case runs the hook for all loaded environments.
# Second case runs the hook for only the specified environment.

function _buildenv_hook() {
  local _hook=$1
  shift
  for _envname in $BUILDENV_LOADED;do
    _buildenv_debug "Running $_hook for $_envname"
    _buildenv_env_hook $_hook $_envname
  done
  for _modname in $BUILDENV_EXTENSIONS;do
    _buildenv_debug "Running $_hook for $_modname extension"
    _buildenv_ext_hook $_hook $_modname
  done
  _buildenv_debug "Ran $_hook"
}

function _buildenv_env_hook() {
  local _hook=$1
  local _envname=$2
  _buildenv_load_file "environments/$_envname/$_hook.sh"
}

function _buildenv_ext_hook() {
  local _hook=$1
  local _modname=$2
  _buildenv_load_file "extensions/$_modname/$_hook.sh"
}


