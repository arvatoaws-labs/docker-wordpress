#!/bin/bash
set -e

cd /app

if [ "$SLEEP" = "" ]
then
   echo "starting immediately"
else
   echo "sleeping for $SLEEP seconds..."
   sleep $SLEEP
fi

echo "running wp cronjobs..."
wp cron event run --due-now