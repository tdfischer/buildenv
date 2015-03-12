if [ ! -d "$BUILDENV_PATH/rbenv" ];then
  git clone https://github.com/sstephenson/rbenv.git $BUILDENV_PATH/rbenv
  git clone https://github.com/sstephenson/ruby-build.git $BUILDENV_PATH/rbenv/plugins/ruby-build
fi

_buildenv_set RBENV_ROOT "$BUILDENV_PATH/rbenv"
_buildenv_set RUBYLIB "$BUILDENV_PATH/lib/ruby:$RUBYLIB"
_buildenv_set GEM_PATH "$BUILDENV_PATH/lib/ruby/gems"
_buildenv_set GEM_HOME "$BUILDENV_PATH/lib/ruby/gems"
PATH=$BUILDENV_PATH/rbenv/bin:$BUILDENV_PATH/lib/ruby/gems/bin:$BUILDENV_PATH/rbenv/shims:$PATH
eval "$(rbenv init -)"
