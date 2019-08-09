#!/bin/bash
set -e

if [ "$MYSQL_ROOT_PASSWORD" = "" ]
then
  echo "skipping database creation"
else
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -se"GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* To '$MYSQL_USER@%' IDENTIFIED BY '$MYSQL_PASSWORD';"
fi