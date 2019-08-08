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

if [ "$MYSQL_ROOT_PASSWORD" = "" ]
then
  echo "skipping database creation"
else
  echo "creating database"
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -se"CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
  echo "creating database user"
  mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -se"GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* To '$MYSQL_USER' IDENTIFIED BY '$MYSQL_PASSWORD';"
fi

echo "installing wp core if necessary..."
wp core is-installed --allow-root || wp core install --url="$WORDPRESS_BLOGURL" --title="$WORDPRESS_BLOGNAME" --admin_user="$WORDPRESS_USERNAME" --admin_password="$WORDPRESS_PASSWORD" --admin_email="$WORDPRESS_EMAIL" --skip-email --allow-root

sleep 1

echo "updating wp core database if necessary..."
wp core update-db --allow-root

sleep 1

echo "verifying wp core checksums..."
wp core verify-checksums --allow-root

sleep 1

echo "updating admin user settings..."
wp user update $WORDPRESS_USERNAME --user_pass="$WORDPRESS_PASSWORD" --user_email="$WORDPRESS_EMAIL" --skip-email --allow-root

