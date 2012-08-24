_buildenv_vimfiles=""
function _buildenv_vim_viminit() {
  local _vimrc=""
  _oifs=$IFS
  IFS=":"
  for _rc in $_buildenv_vimfiles;do
    if [ -f "$_rc" ];then
      _vimrc="source $_rc|"
    fi
  done
  IFS=$_oifs
  echo $_vimrc
}

function _buildenv_vim_add_vimrc() {
  export _buildenv_vimfiles="${_buildenv_vimfiles}:${1}"
  _buildenv_debug "Loading vimrc ${1}"
}

_buildenv_vim_add_vimrc ~/.vimrc

export VIMINIT=$(_buildenv_vim_viminit)
