function configure_buildenv() {
  if [ ! -f ./configure -a -f ./autogen.sh ]; then
    ./autogen.sh --prefix=$BUILDENV_PATH
  else
    ./configure --prefix=$BUILDENV_PATH
  fi
}
