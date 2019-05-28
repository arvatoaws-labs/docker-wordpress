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

echo "waiting for mysql server..."
while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
    sleep 1
    echo -n .
done

/usr/bin/php amazon-s3-migrate.php