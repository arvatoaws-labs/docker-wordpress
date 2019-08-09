#!/bin/bash

if [ "$WP_PLUGINS" = "" ]
then
   echo "please define WP_PLUGINS"
   exit 1
fi

cd /app

for plugin in $WP_PLUGINS
do
  echo "activating wp plugin $plugin..."
  
  PLUGIN_CHECK="$(wp plugin is-installed $plugin)"
  if [ $? -eq 0 ]; then
    PLUGIN_CHECK="$(wp plugin is-active $plugin)"
    if [ $? -eq 0 ]; then
      echo "error wp plugin $plugin is already active"
    else
      wp plugin activate $plugin --allow-root
    fi
  else
    echo "error wp plugin $plugin is not installed"
  fi
  sleep 1
done
