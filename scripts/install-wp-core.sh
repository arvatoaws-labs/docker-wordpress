#!/bin/bash
set -e

cd /app

echo "installing wp core if necessary..."
wp core is-installed --allow-root || wp core install --url="$WORDPRESS_BLOGURL" --title="$WORDPRESS_BLOGNAME" --admin_user="$WORDPRESS_USERNAME" --admin_password="$WORDPRESS_PASSWORD" --admin_email="$WORDPRESS_EMAIL" --skip-email --allow-root
