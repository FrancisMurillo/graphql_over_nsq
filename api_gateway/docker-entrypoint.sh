#!/bin/bash

set -e

echo "Updating dependencies if any uninstalled packages..."
HEX_HTTP_CONCURRENCY=1 HEX_HTTP_TIMEOUT=120 mix deps.get

exec "$@"
