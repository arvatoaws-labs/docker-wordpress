#!/bin/bash
set -e

cd /app

echo "verifying wp core checksums..."
wp core verify-checksums --allow-root
