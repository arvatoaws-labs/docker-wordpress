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

echo "waiting for mysql server..."
while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
    sleep 1
    echo -n .
done

echo "running wp cronjobs..."
wp cron event run --due-now