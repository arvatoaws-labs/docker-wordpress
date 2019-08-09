#!/bin/bash
set -e

echo "waiting for mysql server..."

if [ "$MYSQL_ROOT_PASSWORD" = "" ]
then
  echo "skipping database connection test because of missing root password"
else
  while ! mysqladmin status -h"$MYSQL_HOST" -u"$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" ; do
    sleep 1
    echo -n .
  done
fi