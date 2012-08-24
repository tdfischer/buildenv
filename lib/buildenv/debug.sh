function _buildenv_debug() {
  if [ -n "$BUILDENV_DEBUG" ];then
    echo "D: $@" 1>&2
  fi
}

