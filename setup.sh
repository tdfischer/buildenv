# setup.sh - Configures a build environment.
# by Trever Fischer <wm161@wm161.net>
#
# To use, add the following to your .bashrc:
# source /path/to/setup.sh
#
# To configure, export the following variables before sourcing this file:
#   BUILDENV_HOME - The place to look for your *-env.d/ files. Defaults to `dirname /path/to/setup.sh`
#   BUILDENV_PREFIX - Where you will install your sources. Defaults to /opt/buildenv/

export BUILDENV_VERSION="0.1.0"
export BUILDENV_HOME=${BUILDENV_HOME:-`dirname $BASH_SOURCE`}
export BUILDENV_PREFIX=${BUILDENV_PREFIX:-/opt/buildenv}
export BUILDENV_BUILD_ROOT=${BUILDENV_BUILD:-$HOME/build/}
export BUILDENV_SRC_ROOT=${BUILDENV_SRC:-$HOME/Projects/}
export BUILDENV_LOADED=""
export BUILDENV_EXTENSIONS=""

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

# Sources a file if it exists
# Usage:
# _buildenv_source_file /path/to/file
#
# Returns 0 on success, 1 on failure.
function _buildenv_source_file() {
  _buildenv_debug "Sourcing $1"
  if [ -f "$1" ];then
    source $1
    return 0
  fi
  return 1
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

function _buildenv_run_hook() {
  local _hook=$1
  local _modname=$2
  local _script="$BUILDENV_HOME/$_hook.d/$_modname.sh"
  _buildenv_debug $_script
  _buildenv_source_file "$BUILDENV_HOME/$_hook.d/$_modname.sh"
  _buildenv_source_file "$BUILDENV_HOME/config/$BUILDENV_CONFIG-hooks/$_hook.d/$_modname.sh"
}

function _buildenv_env_hook() {
  local _hook=$1
  local _envname=$2
  _buildenv_run_hook "$_hook-env" $_envname
}

function _buildenv_ext_hook() {
  local _hook=$1
  local _modname=$2
  _buildenv_run_hook "$_hook-ext" $_modname
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
  _buildenv_env_hook init $_envname
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
  _buildenv_env_hook teardown $1
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

function _buildenv_ext_complete() { 
  local cur prev environs
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  for e in $(ls $BUILDENV_HOME/*-ext.d/*);do
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

complete -F _buildenv_ext_complete buildenv_load_extension

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

function _buildenv_prompt_append() {
  export BUILDENV_PROMPT="${BUILDENV_PROMPT}${@}"
}

function _buildenv_build_prompt() {
  export BUILDENV_PROMPT=""
  if [ -n "$BUILDENV_BIG_PROMPT" ];then
    _buildenv_prompt_append "$BUILDENV_MASTER"
    _buildenv_hook prompt
    if [ -n "$BUILDENV_PROMPT" ];then
      echo "$BUILDENV_PROMPT"
    fi
  fi
  _src=${PWD#$BUILDENV_SRC_ROOT}
  _build=${PWD#$BUILDENV_BUILD_ROOT}
  _type=""
  if [ "$PWD" != "$_src" ];then
    _type="src"
    _project="$_src"
  elif [ "$PWD" != "$_build" ];then
    _type="bld"
    _project="$_build"
  fi
  export BUILDENV_SOURCE="$BUILDENV_SRC_ROOT/$_project"
  export BUILDENV_BUILD="$BUILDENV_BUILD_ROOT/$_project"
  export BUILDENV_CWD_TYPE="$_type"
  _buildenv_debug "CWD: $PWD"
  _buildenv_debug "Current source: $BUILDENV_SOURCE $_src"
  _buildenv_debug "Current build: $BUILDENV_BUILD $_build"
}

function buildenv_load_extension() {
  export BUILDENV_EXTENSIONS=" ${1}${BUILDENV_EXTENSIONS}"
  _buildenv_ext_hook init $1
}

function _buildenv_load_defaults() {
  local _parent=$(readlink /proc/$PPID/exe)
  _parent=${_parent##*/bin/}
  _buildenv_load_config $USER
  _buildenv_load_config $_parent
  _buildenv_load_config $TERM
  _buildenv_load_config $DESKTOP_SESSION
  local _host=$HOSTNAME
  while [ "${_host}" != "${_host/./}" ];do
    _buildenv_load_config $_host
    _host=${_host#*.}
  done
}

function _buildenv_load_config() {
  local _config="$BUILDENV_HOME/config/$1.sh"
  local _ret=1
  export BUILDENV_OLD_CONFIG=${BUILDENV_CONFIG}
  export BUILDENV_CONFIG=$1
  _buildenv_hook pre-load-config
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
      _buildenv_hook firstrun
    fi
    _buildenv_load $_envname
  done
  _buildenv_save CONFIG_SITE
  export CONFIG_SITE="${BUILDENV_HOME}/config.site"
  echo -e "Loaded environments: \E[1;33m$BUILDENV_LOADED\E[0m"
  echo -e "Master environment: \E[1;32m$BUILDENV_MASTER\E[0m"
  _buildenv_hook loaded
}

# Change to the source directory
function buildenv_cs() {
  cd $BUILDENV_SOURCE
}

# Change to the build directory
function buildenv_cb() {
  if [ ! -d "$BUILDENV_BUILD" ];then
    echo "Creating new build directory in $BUILDENV_BUILD"
    mkdir -p $BUILDENV_BUILD
  fi
  cd $BUILDENV_BUILD
}

function buildenv_build() {
  cb
  echo "Building in $BUILDENV_BUILD"
  if [ -f "$BUILDENV_SOURCE/CMakeLists.txt" ];then
    echo "Running cmake"
    cmake -DCMAKE_INSTALL_PREFIX=$(_buildenv_pkg_get PATH $BUILDENV_MASTER) $BUILDENV_SOURCE
  else
    echo "Don't know how to handle this build system!"
  fi
}

function buildenv_report() {
  echo "Buildenv $BUILDENV_VERSION loaded."
  echo "Home: $BUILDENV_HOME"
  echo "Build root: $BUILDENV_BUILD_ROOT"
  echo "Source root: $BUILDENV_SOURCE_ROOT"
  echo "Current buildenv: $BUILDENV_MASTER"
  echo "Extensions: $BUILDENV_EXTENSIONS"
  _buildenv_hook report
}

export PROMPT_COMMAND="_buildenv_build_prompt;$PROMPT_COMMAND"
_buildenv_load_defaults
_buildenv_debug "Buildenv $BUILDENV_VERSION loaded."

source $BUILDENV_HOME/lib/buildenv/aliases.sh
