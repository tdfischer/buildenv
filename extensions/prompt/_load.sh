_buildenv_lib_include buildenv/prompt.sh

function _buildenv_dir_type() {
  if [ -n "$BUILDENV_CWD_TYPE" ];then
    echo "[$BUILDENV_CWD_TYPE]"
  fi
}
