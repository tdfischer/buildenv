# arg1 - var name
# arg2 - package
function _buildenv_pkg_varname() {
  _buildenv_debug $@
  echo "BUILDENV_$1_$(echo $2 | sed -e 's/[^a-zA-Z0-9_]/_/')"
}

function _buildenv_pkg_get() {
  local _var=$(_buildenv_pkg_varname $1 $2)
  echo ${!_var}
}

function _buildenv_pkg_set() {
  local _var=$(_buildenv_pkg_varname $1 $2)
  export $_var=$3
}

function _buildenv_set() {
  local _varname=$1
  shift
  _buildenv_save $_varname
  export ${_varname}="$@"
  echo "> ${_varname}=$@"
}

function _buildenv_save() {
  local _varname=$1
  local _savevar="_buildenv_save_$_varname"
  # Check if we've already saved it
  if [ "$_buildenv_saved_vars" == "${_buildenv_saved_vars/$_varname /}" ];then
    export ${_savevar}="${!_varname}"
    _buildenv_saved_vars="${_varname} ${_buildenv_saved_vars/$_varname /}"
  fi
}

function _buildenv_restore() {
  local _varname=$1
  local _savevar="_buildenv_save_$_varname"
  export ${_varname}="${!_savevar}"
  unset ${_savevar}
  _buildenv_saved_vars=${_buildenv_saved_vars/$_varname /}
} 

function _buildenv_restore_all() {
  _buildenv_hook restore-all
  for v in $_buildenv_saved_vars;do
    _buildenv_restore $v
  done
}


