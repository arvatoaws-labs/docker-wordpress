#!/bin/bash
set -e

cd /app

echo "updating wp core database if necessary..."
wp core update-db --allow-root
