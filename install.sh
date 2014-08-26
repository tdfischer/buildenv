if [ -n "$BUILDENV_VERSION" ];then
  echo "You already have $BUILDENV_VERSION installed at $BUILDENV_HOME."
fi
mydir=$(readlink -e $0)
mydir=$(dirname $mydir)

(
  cd $mydir
  git submodule init
  git submodule update
)

echo "# Added by $mydir/install.sh" >> ~/.bashrc
echo "# Loads buildenv." >> ~/.bashrc
echo "if [ ! -f $mydir/setup.sh ];then" >> ~/.bashrc
echo "  echo 'I tried loading buildenv from $mydir/setup.sh, but it could not be found.'" >> ~/.bashrc
echo "else" >> ~/.bashrc
echo "  source $mydir/setup.sh" >> ~/.bashrc
echo "fi" >> ~/.bashrc

echo "Installed to ~/.bashrc."
echo "For best results, execute the following:"
echo "# mkdir -p $BUILDENV_PREFIX"
echo "# chown $USER $BUILDENV_PREFIX"
echo "This will allow you to run 'make install' without sudo."
echo "To activate buildenv now, execute the following:"
echo "$ source $mydir/setup.sh"
