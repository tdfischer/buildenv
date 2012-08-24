_buildenv_loaded=""
function _buildenv_lib_include() {
  local _oifs=$IFS
  IFS=":"
  for inc in $_buildenv_loaded;do
    if [ "$inc" == "$1" ];then
      return 0
    fi
  done
  source "$BUILDENV_HOME/lib/$1"
  _buildenv_loaded="$1:$_buildenv_loaded"
  return 0
}

