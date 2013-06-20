_buildenv_declare_feature virtualenv "Python virtualenv"

function _buildenv_virtualenv_display() {
  if [ -n "$_buildenv_virtual_name" ];then
    echo "$_buildenv_virtual_name~"
  elif [ -n "$VIRTUAL_ENV" ];then
    echo "$(_buildenv_virtualenv_relpath "$VIRTUAL_ENV")~"
  fi
}

function _buildenv_virtualenv_relpath() {
    [ $# -ge 1 ] && [ $# -le 2 ] || return 1
    current="${2:+"$1"}"
    target="${2:-"$1"}"
    [ "$target" != . ] || target=/
    target="/${target##/}"
    [ "$current" != . ] || current=/
    current="${current:="/"}"
    current="/${current##/}"
    appendix="${target##/}"
    relative=''
    while appendix="${target#"$current"/}"
        [ "$current" != '/' ] && [ "$appendix" = "$target" ]; do
        if [ "$current" = "$appendix" ]; then
            relative="${relative:-.}"
            echo "${relative#/}"
            return 0
        fi
        current="${current%/*}"
        relative="$relative${relative:+/}.."
    done
    relative="$relative${relative:+${appendix:+/}}${appendix#/}"
    echo "$relative"
}
