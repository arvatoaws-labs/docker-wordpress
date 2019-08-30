#!/bin/bash
set -e

if [ "$WP_IMPORT_DUMP" = "" ]
then
   echo "please define WP_IMPORT_DUMP"
   exit 1
fi

echo "preparing dump file"

cp $WP_IMPORT_DUMP /tmp/src.dump

sed -i 's/CREATE DATABASE/-- CREATE DATABASE/g' /tmp/src.dump
sed -i 's/USE /-- USE/g' /tmp/src.dump

echo "DROP DATABASE IF EXISTS $MYSQL_DATABASE;" > /tmp/new.dump
echo "CREATE DATABASE $MYSQL_DATABASE DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;" >> /tmp/new.dump
echo "USE $MYSQL_DATABASE;" >> /tmp/new.dump

cat /tmp/src.dump >> /tmp/new.dump

echo "importing dump file into mysql"

mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST < /tmp/new.dump