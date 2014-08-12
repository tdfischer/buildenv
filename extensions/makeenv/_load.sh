_buildenv_lib_include buildenv/platform.sh

function makeenv() {
  if [ -n $BUILDENV_LOADED ];then
    buildenv
  fi
  local makefile=$(_buildenv_environment_path Makefile)
  if [ -f $makefile ];then
    (
      mkdir -p $BUILDENV_PATH/makeenv
      cd $BUILDENV_PATH/makeenv
      PATH=$BUILDENV_HOME/extensions/makeenv/bin:$PATH make -I $BUILDENV_HOME/extensions/makenv/makelib -f $makefile $@
    )
  fi
}
