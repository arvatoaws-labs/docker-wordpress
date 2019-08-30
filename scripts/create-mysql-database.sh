#!/bin/bash
set -e

if [ "$MYSQL_ROOT_PASSWORD" = "" ]
then
  echo "skipping database creation because of missing root password"
else
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -se"CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
fi