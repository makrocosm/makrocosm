#!/bin/sh

# Include the makrocosm scripts in PATH for convenience
export PATH="$MKDISTRO_ROOT/bin:$PATH"

exec "$@"
