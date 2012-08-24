function _buildenv_auto_add_dep() {
  _buildenv_debug "Autoloading dep: $@"
  local _env="$BUILDENV_HOME/init-env.d/$BUILDENV_MASTER.sh"
  if [ ! -f "$_env" ];then
    echo "Dependency against $1 found, loading buildenv."
    buildenv_add_dependency $1
    _buildenv_load $1
  fi
  grep -q "^_buildenv_declare_dependency '$1'$" $_env 2>/dev/null
  if [ $? -gt 0 ];then
    echo "Dependency against $1 found, loading buildenv."
    buildenv_add_dependency $1
    _buildenv_load $1
  fi
}

function _buildenv_pkg_config_parse_package() {
  echo "$1" | grep -qE -- "-([0-9]\.?)+$"
  if [ $? -eq 0 ];then
    _buildenv_auto_add_dep ${1%-*}
  else
# Strip out bad parsing, such as "0.8"
    echo "$1" | grep -qvE "^([0-9]\.?)+$"
    if [ $? -eq 0 ];then
      _buildenv_auto_add_dep ${1%-*}
    fi
  fi
}

function _buildenv_pkg_config_parse() {
  local _comparator="n"
  _buildenv_debug "Parsing $1"
  while [ $# -gt 0 ];do
    _buildenv_debug "parse: $1"
    case "$1" in
      --atleast-pkgconfig-version)
        return 0
        ;;
      -*)
        ;;
      *=*|">")
        _comparator="y"
        ;;
      *)
        if [ -n "$1" -a "$_comparator" == "n" ];then
          _buildenv_pkg_config_parse_package $1
        fi
        if [ "$_comparator" == "y" ];then
          _comparator="n"
        fi
        ;;
    esac
    shift;
  done
}

function _buildenv_pkg_config() {
  _exec=""
  while [ $# -gt 0 ];do
    _exec="$_exec \"$1\""
    shift;
    _buildenv_pkg_config_parse $1 1>&2
  done
  eval $_exec
  _ret=$?
  return $_ret
}

_buildenv_set PKG_CONFIG_PATH "$BUILDENV_PATH/lib/pkgconfig/:$PKG_CONFIG_PATH"
