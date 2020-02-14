#!/bin/bash

set -e

echo "Updating dependencies if any uninstalled packages..."
mix deps.get

echo "Running migrations if any..."
mix ecto.create --no-deps-check
mix ecto.migrate --no-deps-check
mix ecto.seed

exec "$@"
