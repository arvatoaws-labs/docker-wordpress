#!/bin/bash
set -e

echo "waiting for mysql server..."
while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
  sleep 1
  echo -n .
done