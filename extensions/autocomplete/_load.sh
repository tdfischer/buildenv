function _buildenv_complete() { 
  local cur prev environs
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  for e in $(ls $BUILDENV_HOME/environments/*);do
    e=`basename $e .sh`
    environs="$environs $e"
  done
  for e in $(find $BUILDENV_PREFIX -maxdepth 1 -mindepth 1 -type d);do
    e=`basename $e`
    environs="$environs $e"
  done

  COMPREPLY=( $(compgen -W "${environs}" -- ${cur}) )
  return 0
}

function _buildenv_ext_complete() { 
  local cur prev environs
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  for e in $(ls $BUILDENV_HOME/extensions/*);do
    e=`basename $e .sh`
    environs="$environs $e"
  done
  for e in $(find $BUILDENV_PREFIX -maxdepth 1 -mindepth 1 -type d);do
    e=`basename $e`
    environs="$environs $e"
  done

  COMPREPLY=( $(compgen -W "${environs}" -- ${cur}) )
  return 0
}

complete -F _buildenv_complete buildenv
complete -F _buildenv_ext_complete buildenv_load_extension
