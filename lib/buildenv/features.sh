_buildenv_lib_include buildenv/hooks.sh
_buildenv_lib_include buildenv/debug.sh
_buildenv_lib_include buildenv/buildenv.sh
_buildenv_lib_include buildenv/configuration.sh

function _buildenv_declare_feature() {
  local _name=$1
  local _description=$2
  _buildenv_debug "_buildenv_declare_feature not implemented"
}

function _buildenv_disable_feature() {
  _buildenv_is_feature_enabled $1 || return 0
  _buildenv_debug "Disabling feature $1"
  local _feature=$1
  _buildenv_hook "feature-$_feature-disable"
  BUILDENV_FEATURES=${BUILDENV_FEATURES/ $_feature / }
}

function _buildenv_enable_feature() {
  _buildenv_is_active || return 1
  _buildenv_is_feature_enabled $1 && return 0
  _buildenv_hook "Enabling feature $1"
  local _feature=$1
  _buildenv_hook "feature-$_feature-enable"
  export BUILDENV_FEATURES=" $_feature$BUILDENV_FEATURES"
}

function _buildenv_is_feature_enabled() {
  if [[ "$BUILDENV_FEATURES" != "${BUILDENV_FEATURES/ $1 /}" ]];then
    return 0
  fi
  return 1
}
