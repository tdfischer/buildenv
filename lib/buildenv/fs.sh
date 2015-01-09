source $BUILDENV_HOME/lib/load.sh

_buildenv_lib_include buildenv/debug.sh

# Sources a file if it exists
# Usage:
# _buildenv_source_file /path/to/file
#
# Returns 0 on success, 1 on failure.
function _buildenv_source_file() {
  if [ -f "$1" ];then
    _buildenv_debug "Sourcing $1"
    source $1
    return 0
  fi
  return 1
}

# Searches for and loads a file
# Checks the following locations:
#  $BUILDENV_HOME/$file
#  $BUILDENV_HOME/config/$BUILDENV_CONFIG/$file
#  ~/.buildenv/$file
#  ~/.buildenv/config/$BUILDENV_CONFIG/$file
function _buildenv_load_file() {
  _buildenv_source_file $BUILDENV_HOME/$1
  _buildenv_source_file $BUILDENV_HOME/config/$BUILDENV_CONFIG/$1
  _buildenv_source_file ~/.buildenv/$1
  _buildenv_source_file ~/.buildenv/config/$BUILDENV_CONFIG/$1
}

function _buildenv_environment_path() {
  if [ -n "$1" ];then
    echo "$BUILDENV_HOME/environments/$BUILDENV_MASTER/$1"
  else
    echo "$BUILDENV_HOME/environments/$BUILDENV_MASTER"
  fi
}

# Symlinks a file in $HOME to config/$CONFIG/dotfiles/$1
function _buildenv_config_symlink() {
  local _src=$HOME/$1
  local _dst=$BUILDENV_HOME/config/$BUILDENV_CONFIG/dotfiles/$1
  _buildenv_debug "Linking $_src to $_dest"
  if [ -L $_src -o ! -e $_src ]; then
    if [ -e $_src ]; then
      unlink $_src || echo "Warning: Could not unlink $_src"
    fi 
    ln -s $_dst $_src || echo "Warning: Could not link $_src to $_dst"
  else
    echo "Warning: $_src is a real file! Not symlinking to $_dst"
  fi
}
