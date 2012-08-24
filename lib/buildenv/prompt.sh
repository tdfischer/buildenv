function _buildenv_prompt_append() {
  export BUILDENV_PROMPT="${BUILDENV_PROMPT}${@}"
}

function _buildenv_build_prompt() {
  export BUILDENV_PROMPT=""
  if [ -n "$BUILDENV_BIG_PROMPT" ];then
    _buildenv_prompt_append "$BUILDENV_MASTER"
    _buildenv_hook prompt
    if [ -n "$BUILDENV_PROMPT" ];then
      echo "$BUILDENV_PROMPT"
    fi
  fi
  _src=${PWD#$BUILDENV_SRC_ROOT}
  _build=${PWD#$BUILDENV_BUILD_ROOT}
  _type=""
  if [ "$PWD" != "$_src" ];then
    _type="src"
    _project="$_src"
  elif [ "$PWD" != "$_build" ];then
    _type="bld"
    _project="$_build"
  fi
  export BUILDENV_SOURCE="$BUILDENV_SRC_ROOT/$_project"
  export BUILDENV_BUILD="$BUILDENV_BUILD_ROOT/$_project"
  export BUILDENV_CWD_TYPE="$_type"
  _buildenv_debug "CWD: $PWD"
  _buildenv_debug "Current source: $BUILDENV_SOURCE $_src"
  _buildenv_debug "Current build: $BUILDENV_BUILD $_build"
}


