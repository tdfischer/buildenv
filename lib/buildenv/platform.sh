function _buildenv_libdir() {
  echo "lib$(_buildenv_libsuffix)"
}

function _buildenv_libsuffix() {
  if [ "$(uname -m)" == "x86_64" ];then
    echo "64"
  fi
}
