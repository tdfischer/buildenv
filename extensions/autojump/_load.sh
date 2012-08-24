if [ ! -d ~/.autojump ];then
  cd $BUILDENV_HOME/lib/autojump/
  echo "Initializing autojump installation"
  ./install.sh >/dev/null
fi
source ~/.autojump/etc/profile.d/autojump.bash
