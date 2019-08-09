#!/bin/bash
set -e

echo "waiting for mysql server..."
while ! mysqladmin status -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" ; do
  sleep 1
  echo -n .
done