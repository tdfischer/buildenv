_buildenv_lib_include buildenv/platform.sh
function cmake_buildenv() {
  cmake -DLIB_SUFFIX=$(_buildenv_libsuffix) -DCMAKE_INSTALL_PREFIX=$BUILDENV_PATH $@
}
