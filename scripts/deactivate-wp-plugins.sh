#!/bin/bash

if [ "$WP_PLUGINS" = "" ]
then
   echo "please define WP_PLUGINS"
   exit 1
fi

cd /app

WP_PLUGINS_ACTIVE=$(timeout 10s wp plugin list | grep -v inactive | grep active | cut -f 1)

for active_plugin in $WP_PLUGINS_ACTIVE
do
#  echo $active_plugin
  for allowed_plugin in $WP_PLUGINS
  do
#    echo $check_plugin
    if [ $active_plugin == $allowed_plugin ]
    then
            #echo "found, keeping $allowed_plugin"
            continue
    else
            #echo "not found, deleting $active_plugin"
            timeout 15s wp plugin deactivate $active_plugin --allow-root
    fi
  done
done
