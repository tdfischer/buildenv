source $(dirname $0)/setup.sh

echo "# Added by $(dirname $0)/install.sh" >> ~/.bashrc
echo "# Loads buildenv." >> ~/.bashrc
echo "source $(dirname $0)/setup.sh" >> ~/.bashrc

echo "Installed to ~/.bashrc."
echo "For best results, execute the following:"
echo "# mkdir -p $BUILDENV_PREFIX"
echo "# chown $USER $BUILDENV_PREFIX"
echo "This will allow you to run 'make install' without sudo."
