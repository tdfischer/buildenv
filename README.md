Writing an environment:
  Place it in environments/<name>/_load.sh
  When unloaded, it will execute environments/<name>/_teardown.sh
  Add hooks to environments/<name>/<hook>.sh

# Available hooks:


## Special hooks:

Hooks that begin with an underscore handle special events that
affect a single buildenv or extension.

_load
  Called once, when the environment or extension is loaded.
  A great place to define any library functions needed.

_teardown
  Called once, when the environment or extension is unloaded.
  A great place to run any cleanup code, such as undefining functions.

## Normal hooks

These hooks represent various events in the buildenv system.

buildenv-loaded
  A new buildenv is loaded

buildenv-unloaded
  A buildenv is unloaded

buildenv-changed
  The current 'master' buildenv is changed

init
  Buildenv is completely loaded

report
  Called from within buildenv_report.

restore-all
  _buildenv_restore_all is about to restore the environment to original values

load-config
  A configuration is activated.

firstrun
  'buildenv' was executed for the first time.
  Useful for any kind of initialization you'd otherwise want to delay until
  you know the user will be actually using buildenv.

prompt
  Whenever the shell prompt is regenerated.
  WARNING: This function needs to be pretty much *instant*, as bash does not
  show the prompt 'till it is done.

# Update Mechanism

There is a rudimentary update mechanism that assumes $BUILDENV_HOME is a git
repository, originally cloned from somewhere (has an 'origin' remote).

To use, run buildenv_update
