function _buildenv_dir_type() {
  if [ -n "$BUILDENV_CWD_TYPE" ];then
    echo "[$BUILDENV_CWD_TYPE]"
  fi
}

export PS1="\[\033[1;32m\]\$BUILDENV_MASTER\$(_buildenv_dir_type)\[\033[0m\]$PS1"
