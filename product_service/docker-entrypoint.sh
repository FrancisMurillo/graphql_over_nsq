#!/bin/bash

set -e

echo "Updating dependencies if any uninstalled packages..."
HEX_HTTP_CONCURRENCY=1 HEX_HTTP_TIMEOUT=120 mix deps.get

echo "Running migrations if any..."
mix ecto.create --no-deps-check
mix ecto.migrate --no-deps-check
mix ecto.seed

exec "$@"
