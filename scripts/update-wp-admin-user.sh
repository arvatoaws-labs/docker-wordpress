#!/bin/bash
set -e

cd /app

echo "updating admin user settings..."
wp user update $WORDPRESS_USERNAME --user_pass="$WORDPRESS_PASSWORD" --user_email="$WORDPRESS_EMAIL" --skip-email --allow-root
