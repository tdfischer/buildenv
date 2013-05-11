function cmake_buildenv() {
  cmake -DLIB_SUFFIX=$_lib_suffix -DCMAKE_INSTALL_PREFIX=$BUILDENV_PATH $@
}
