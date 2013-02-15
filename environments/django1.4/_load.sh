echo "Setting up virtualenv in $BUILDENV_PATH_django1_4"
virtualenv --no-site-packages $BUILDENV_PATH_django1_4
export VIRTUAL_ENV_DISABLE_PROMPT=1
source $BUILDENV_PATH_django1_4/bin/activate
pip install "Django>=1.4"
