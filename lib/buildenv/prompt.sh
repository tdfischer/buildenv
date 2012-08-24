function _buildenv_prompt_append() {
  export BUILDENV_PROMPT="${BUILDENV_PROMPT}${@}"
}

function _buildenv_save_prompt() {
  _buildenv_base_prompt="$1"
}

function _buildenv_build_prompt() {
  local _ps=$PS1
  _buildenv_restore PS1
  if [ "$PS1" != "$_ps" -a "$_ps" != "$BUILDENV_PROMPT$PS1" ];then
    PS1=$_ps
  fi
  export BUILDENV_PROMPT=""
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
  _buildenv_hook prompt
  _buildenv_restore PS1
  _buildenv_set PS1 "$BUILDENV_PROMPT$PS1"
}


