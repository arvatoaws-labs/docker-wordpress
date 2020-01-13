#!/bin/bash

if [ "$WP_PLUGINS" = "" ]
then
   echo "please define WP_PLUGINS"
   exit 1
fi

WP_CHECK_ARGS="--allow-root --debug"
WP_ACTIVATE_ARGS="--allow-root --debug"

if [ "$WP_USE_MULTISITE" = "true" ]
then
   WP_ACTIVATE_ARGS="$WP_ACTIVATE_ARGS --network"
fi

cd /app

for plugin in $WP_PLUGINS
do
  echo "activating wp plugin $plugin..."

  PLUGIN_CHECK="$(timeout 5s wp plugin is-installed $plugin $WP_CHECK_ARGS)"
  if [ $? -eq 0 ]; then
    PLUGIN_CHECK="$(timeout 5s wp plugin is-active $plugin $WP_CHECK_ARGS)"
    if [ $? -eq 0 ]; then
      echo "error wp plugin $plugin is already active"
    else
      timeout 10s wp plugin activate $plugin $WP_ACTIVATE_ARGS
    fi
  else
    echo "error wp plugin $plugin is not installed"
  fi
  sleep 1
done
