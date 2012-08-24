source $BUILDENV_HOME/lib/buildenv/update.sh
exec 3>&2
exec 1>&2
exec 2>/dev/null
_buildenv_background_update_check 2>&3 3>&- &
