function configure_buildenv() {
  if [ ! -f ./configure -a -f ./autogen.sh ]; then
    ./autogen.sh --prefix=$BUILDENV_PATH --libdir=$BUILDENV_PATH/$(_buildenv_libdir)
  else
    ./configure --prefix=$BUILDENV_PATH --libdir=$BUILDENV_PATH/$(_buildenv_libdir)
  fi
}
