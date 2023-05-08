#!/bin/sh

set -e
# Handle a kill signal before the final "exec" command runs
trap "{ exit 0; }" TERM INT

echo "Docker EntryPoint enter"

# strip off "/bin/sh -c" args from a string CMD
if [ $# -gt 1 ] && [ "$1" = "/bin/sh" ] && [ "$2" = "-c" ]; then
  shift 2
  eval "set -- $1"
fi

# run a shell if there is no command passed
if [ $# = 0 ]; then
  if [ -x /bin/bash ]; then
    set -- /bin/bash
  else
    set -- /bin/sh
  fi
fi

# run command with exec to pass control
echo "Running CMD: $@"
exec "$@"
