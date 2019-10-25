#!/bin/bash
set -e

if [ "$WP_IMPORT_DUMP" = "" ]
then
   echo "please define WP_IMPORT_DUMP"
   exit 1
fi

if [ "$WP_SITE_ID" = "" ]
then
   echo "please define WP_SITE_ID"
   exit 1
fi

echo "preparing dump file"

INFILE=$WP_IMPORT_DUMP
TMPFILE=/tmp/tmp.dump
OUTFILE=/tmp/new.dump

echo "USE $MYSQL_DATABASE;" > $OUTFILE

cp $WP_IMPORT_DUMP $TMPFILE

sed -i -e 's/^CREATE DATABASE /-- CREATE DATABASE /g' $TMPFILE
sed -i -e 's/^USE /-- USE /g' $TMPFILE

sed -i 's/`wp_/`wp_'$WP_SITE_ID'_/g' $TMPFILE
sed -i 's/ENGINE=MyISAM/ENGINE=InnoDB/g' $TMPFILE

grep "CREATE TABLE IF NOT EXISTS" $TMPFILE | grep wp_ | awk '{print "DROP TABLE IF EXISTS " $6 ";" }' >> $OUTFILE
grep "CREATE TABLE" $TMPFILE | grep wp_ | awk '{print "DROP TABLE IF EXISTS " $3 ";" }' >> $OUTFILE

cat $TMPFILE >> $OUTFILE

echo "importing into database"

mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST --default_character_set utf8 < $OUTFILE