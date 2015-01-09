# setup.sh - Configures a build environment.
# by Torrie Fischer <tdfischer@hackerbots.net>
#
# To use, add the following to your .bashrc:
# source /path/to/setup.sh
#
# To configure, export the following variables before sourcing this file:
#   BUILDENV_HOME - The place to look for your *-env.d/ files. Defaults to `dirname /path/to/setup.sh`
#   BUILDENV_PREFIX - Where you will install your sources. Defaults to /opt/buildenv/

#export BUILDENV_DEBUG="1"

export BUILDENV_HOME=${BUILDENV_HOME:-`dirname $BASH_SOURCE`}
export BUILDENV_PREFIX=${BUILDENV_PREFIX:-/opt/buildenv}
export BUILDENV_BUILD_ROOT=${BUILDENV_BUILD:-$HOME/build/}
export BUILDENV_SRC_ROOT=${BUILDENV_SRC:-$HOME/Projects/}
export BUILDENV_LOADED=" "
export BUILDENV_EXTENSIONS=" "
export BUILDENV_FEATURES=" "

source $BUILDENV_HOME/lib/load.sh
_buildenv_lib_include buildenv/debug.sh
_buildenv_lib_include buildenv/hooks.sh
_buildenv_lib_include buildenv/buildenv.sh
_buildenv_lib_include buildenv/prompt.sh
_buildenv_lib_include buildenv/vars.sh
_buildenv_lib_include buildenv/features.sh
_buildenv_lib_include buildenv/fs.sh


function buildenv_add_dependency() {
  _buildenv_is_active || return
  _buildenv_append_environment "_buildenv_declare_dependency '$1'"
  buildenv $1
  echo "Added dependency to $BUILDENV_MASTER"
}

function buildenv_load_extension() {
  if [[ "$_buildenv_loading_ext" != "$1" ]];then
    if [[ "$BUILDENV_EXTENSIONS" == "${BUILDENV_EXTENSIONS/ $1 /}" ]];then
      export BUILDENV_EXTENSIONS=" ${1}${BUILDENV_EXTENSIONS}"
      _buildenv_loading_ext=$1
      _buildenv_ext_hook "_load" $1
      unset _buildenv_loading_ext
    fi
  fi
}

function buildenv() {
  local _newmaster=""
  OPTIND=1
  while getopts "lm:" opt;do
    case $opt in
      l)
        echo -e "Loaded environments: \E[1;33m$BUILDENV_LOADED\E[0m";
        echo -e "Master environment: \E[1;32m$BUILDENV_MASTER\E[0m"
        return 0
        ;;
      m)
        _newmaster=$OPTARG
        ;;
      \?)
        echo "Usage: buildenv [-m new-master] [-l] package-name"
        return 0
        ;;
    esac
  done
  shift $((OPTIND-1))
  if [ -z "$_newmaster" ];then
    _buildenv_autodetect
    local _envs_to_load=${@:-$_buildenv_auto_name}
  fi 

  for _envname in $_envs_to_load;do
    if [ -z "$BUILDENV_MASTER" ];then
      export BUILDENV_MASTER=$_envname
      _buildenv_hook firstrun
    fi
    _buildenv_load $_envname
  done
  if [ -n "$_newmaster" ]; then
    if [ -z "$BUILDENV_MASTER" ];then
      export BUILDENV_MASTER=$_newmaster
      _buildenv_hook firstrun
    else
      export BUILDENV_MASTER=$_newmaster
    fi
    echo "Setting master buildenv to $_newmaster"
    _buildenv_load $_newmaster
  fi
  #_buildenv_set CONFIG_SITE "${BUILDENV_HOME}/config.site"
  buildenv -l
  _buildenv_hook buildenv-changed
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
  echo "Source root: $BUILDENV_SRC_ROOT"
  echo "Master buildenv: $BUILDENV_MASTER"
  echo "Loaded buildenvs: $BUILDENV_LOADED"
  echo "Extensions: $BUILDENV_EXTENSIONS"
  _buildenv_hook report
}

function buildenv_save() {
  _buildenv_is_active || return
  local _varname=$1
  _buildenv_save_env $BUILDENV_MASTER $_varname
  echo "Saved $_varname."
}

function buildenv_set() {
  local _varname=$1
  shift 1
  _buildenv_set $_varname "$@"
  echo "Saving $BUILDENV_MASTER"
  _buildenv_save_env $BUILDENV_MASTER $_varname
  echo "$_varname=\"${!_varname}\""
}

function buildenv_edit_config() {
  local _hook=$1
  if [ -z "$_hook" ];then
    _hook="_load"
  fi
  _buildenv_edit "${BUILDENV_HOME}/config/$BUILDENV_MASTER/$BUILDENV_CONFIG.sh"
}

function buildenv_edit() {
  _buildenv_is_active || return
  local _edit=$EDITOR
  local _hook=$1
  if [ -z "$_edit" ];then
    _edit="vi"
  fi
  if [ -z "$_hook" ];then
    _hook="_load"
  fi
  $EDITOR "${BUILDENV_HOME}/environments/$BUILDENV_MASTER/$_hook.sh"
}

function buildenv_config() {
  local _configname=$1
  _buildenv_load_config $_configname
  echo "Configuration loaded."
}

function buildenv_update() {
  _buildenv_lib_include buildenv/update.sh
  echo "Downloading update..."
  _buildenv_apply_update
  echo "Reloading buildenv..."
  source $BUILDENV_HOME/setup.sh
}

function buildenv_unload() {
  _buildenv_hook unload
  for _envname in $BUILDENV_LOADED;do
    _buildenv_unload $_envname
  done
  _buildenv_restore_all
  unset BUILDENV_MASTER
  _buildenv_hook unloaded
}

function buildenv_use() {
  _buildenv_append_environment "_buildenv_enable_feature '$1'"
  _buildenv_remove_environment "_buildenv_disable_feature '$1'"
  _buildenv_enable_feature "$1"
}

function buildenv_unuse() {
  _buildenv_append_environment "_buildenv_disable_feature '$1'"
  _buildenv_remove_environment "_buildenv_enable_feature '$1'"
  _buildenv_disable_feature "$1"
}

function buildenv_symlink() {
  _buildenv_config_symlink $1
}

if tty -s;then
  _buildenv_restore_all
  _buildenv_load_defaults
  _buildenv_debug "Buildenv $BUILDENV_VERSION loaded."
  _buildenv_set PROMPT_COMMAND "_buildenv_build_prompt;$PROMPT_COMMAND"
  _buildenv_hook init
fi
