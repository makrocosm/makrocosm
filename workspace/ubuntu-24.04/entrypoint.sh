#!/bin/sh

# Include the makrocosm scripts in PATH for convenience
export PATH="$MAKROCOSM_ROOT/bin:$PATH"

exec "$@"
