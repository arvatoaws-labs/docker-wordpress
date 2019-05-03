#!/bin/bash
set -e

echo "sleeping for 30s..."
sleep 30

cd /app

plugins='amazon-web-services amazon-s3-and-cloudfront'

for plugin in $plugins
do
  echo "activating plugin $plugin..."
  wp plugin is-installed $plugin --allow-root || wp plugin is-active $plugin --allow-root && wp plugin activate $plugin --allow-root
  sleep 1
done
