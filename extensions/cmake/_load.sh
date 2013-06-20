function cmake_buildenv() {
  if [ "$(uname -m)" == "x86_64" ];then
    _lib_suffix=-DLIB_SUFFIX=64
  fi
  cmake $_lib_suffix -DCMAKE_INSTALL_PREFIX=$BUILDENV_PATH $@
}
