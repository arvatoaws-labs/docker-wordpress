#!/bin/bash
set -e

if [ "$MYSQL_ROOT_PASSWORD" = "" ]
then
  echo "skipping database creation"
else
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -se"CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
fi