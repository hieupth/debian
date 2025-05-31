#!/bin/bash
set -euo pipefail

# Run hooks if script exists and is executable
if [ -x "${HOOK_SCRIPT}" ]; then
  /bin/bash ${HOOK_SCRIPT}
fi

# Execute main container command
exec "$@"