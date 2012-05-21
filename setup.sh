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
  for v in $_buildenv_saved_vars;do
    _buildenv_restore $v
  done
}

function _buildenv_hook() {
  HOOK=$1
  local _envname=${2:-$BUILDENV}
  SCRIPT="$BUILDENV_HOME/$HOOK-env.d/$_envname.sh"
  if [ -f "$SCRIPT" ];then
    source "$SCRIPT"
  fi
}

function _buildenv_load() {
  if [ -z "$1" ];then
    echo "Usage: _buildenv_load package-name"
    return
  fi
  local _envname=$1
  if [[ "$BUILDENV_LOADED" != "${BUILDENV_LOADED/ $_envname /}" ]];then
    return
  fi
  BUILDENV_PATH=${BUILDENV_PREFIX}/$_envname
  _pathvar="BUILDENV_PATH_"$(echo $_envname | sed -e s/-/_/)
  export $_pathvar="$BUILDENV_PATH"
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
  local _tmp=$(git config --local --get remote.origin.url)
  if [ -n "_tmp" ];then
    echo $(basename "${_tmp#*:}" .git)
    return 0
  fi
  basename `pwd`
}

function buildenv() {
  local _envname=${1:-$(_buildenv_autodetect)}
  if [ -z "$_envname" ];then
    echo "Usage: buildenv package-name"
    return 0
  fi

  if [ "$BUILDENV" == "$_envname" ];then
    echo "You are already in $BUILDENV."
    return 0
  fi

  if [ "$BUILDENV" != "$_envname" ];then
    echo "Switching from ${BUILDENV:-nothing} to $_envname"
    for f in $BUILDENV_LOADED;do
      _buildenv_unload $f
    done
    _buildenv_restore_all
  fi
  export BUILDENV=$_envname
  _buildenv_load $_envname
  _buildenv_save PS1
  export PS1="\[\e[1;32m\]$BUILDENV>\[\e[0m\]$PS1"
  echo -e "Loaded environments: \E[1;33m$BUILDENV_LOADED\E[0m"
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
