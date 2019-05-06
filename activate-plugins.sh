#!/bin/bash
set -e

if [ "$SLEEP" = "" ]
then
   echo "starting immediately"
else
   echo "sleeping for $SLEEP seconds..."
   sleep $SLEEP
fi

cd /app

plugins='amazon-web-services amazon-s3-and-cloudfront'

for plugin in $plugins
do
  echo "activating wp plugin $plugin..."
  wp plugin is-installed $plugin --allow-root || wp plugin is-active $plugin --allow-root || wp plugin activate $plugin --allow-root
  sleep 1
done
