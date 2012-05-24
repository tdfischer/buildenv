# setup.sh - Configures a build environment.
# by Trever Fischer <wm161@wm161.net>
#
# To use, add the following to your .bashrc:
# source /path/to/setup.sh
#
# To configure, export the following variables before sourcing this file:
#   BUILDENV_HOME - The place to look for your *-env.d/ files. Defaults to `dirname /path/to/setup.sh`
#   BUILDENV_PREFIX - Where you will install your sources. Defaults to /opt/buildenv/

export BUILDENV_HOME=${BUILDENV_HOME:-`dirname $BASH_SOURCE`}
export BUILDENV_PREFIX=${BUILDENV_PREFIX:-/opt/buildenv}
export BUILDENV_LOADED=""
export BUILDENV_DEBUG=""

function _buildenv_debug() {
  if [ -n "$BUILDENV_DEBUG" ];then
    echo "D: $@" 1>&2
  fi
}

function _buildenv_is_active() {
  if [ -z "$BUILDENV_MASTER" ];then
    echo "Must be run within a buildenv."
    return 1
  fi
  return 0
}

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
  local _envlist=${1:-$BUILDENV_LOADED}
  for _envname in $_envlist;do
    _buildenv_debug "Running $_hook for $_envname"
    local _script="$BUILDENV_HOME/$_hook-env.d/$_envname.sh"
    if [ -f "$_script" ];then
      source "$_script"
    fi
  done
  _buildenv_debug "Ran $_hook"
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
  local BUILDENV_PATH=${BUILDENV_PREFIX}/$_envname
  _buildenv_pkg_set PATH $_envname "$BUILDENV_PATH"
  export BUILDENV_LOADED=" $_envname$BUILDENV_LOADED"
  _buildenv_hook init $_envname
  _buildenv_set PKG_CONFIG_PATH "$BUILDENV_PATH/lib/pkgconfig/:$PKG_CONFIG_PATH"
  _buildenv_set PATH "$BUILDENV_PATH/bin:$PATH"
  _buildenv_set LD_LIBRARY_PREFIX "$BUILDENV_PATH/lib/:$LD_LIBRARY_PREFIX"
  _buildenv_set CMAKE_INCLUDE_PATH "$BUILDENV_PATH/include/:$CMAKE_INCLUDE_PATH"
  _buildenv_set CMAKE_LIBRARY_PATH "$BUILDENV_PATH/lib/:$CMAKE_LIBRARY_PATH"
  _buildenv_set CMAKE_PREFIX_PATH "$BUILDENV_PATH:$CMAKE_PREFIX_PATH"
  export BUILDENV_PATH
  echo "Loaded $_envname environment."
}

function _buildenv_unload() {
  if [ -z "$1" ];then
    echo "Usage: _buildenv_unload package-name"
    return
  fi
  _buildenv_hook teardown $1
  BUILDENV_LOADED=${BUILDENV_LOADED/ $1 / }
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

function _buildenv_complete() { 
  local cur prev environs
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  for e in $(ls $BUILDENV_HOME/*-env.d/*);do
    e=`basename $e .sh`
    environs="$environs $e"
  done
  for e in $(find $BUILDENV_PREFIX -maxdepth 1 -mindepth 1 -type d);do
    e=`basename $e`
    environs="$environs $e"
  done

  COMPREPLY=( $(compgen -W "${environs}" -- ${cur}) )
  return 0
}

complete -F _buildenv_complete buildenv

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

function buildenv_add_dependency() {
  _buildenv_is_active || return
  local _env="$BUILDENV_HOME/init-env.d/$BUILDENV_MASTER.sh"
  if [ ! -f "$_env" ];then
    mkdir -p `dirname "$_env"`
    echo "# Autogenerated by $0" > $_env
  fi
  echo "_buildenv_declare_dependency '$1'" >> $_env
  echo "Added dependency to $_env"
}

function buildenv() {
  _buildenv_autodetect
  local _envs_to_load=${@:-$_buildenv_auto_name}
  if [ -z "$_envs_to_load" ];then
    echo "Usage: buildenv package-name"
    return 0
  fi

  for _envname in $_envs_to_load;do
    if [ -z "$BUILDENV_MASTER" ];then
      export BUILDENV_MASTER=$_envname
    fi
    _buildenv_load $_envname
  done
  _buildenv_save CONFIG_SITE
  export CONFIG_SITE="${BUILDENV_HOME}/config.site"
  export PROMPT_COMMAND='echo -en "\e[1;32m${BUILDENV_MASTER})\e[0m"'
  echo -e "Loaded environments: \E[1;33m$BUILDENV_LOADED\E[0m"
  echo -e "Master environment: \E[1;32m$BUILDENV_MASTER\E[0m"
}
