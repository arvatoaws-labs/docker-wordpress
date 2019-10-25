#!/bin/bash
set -e

if [ "$WP_IMPORT_DUMP" = "" ]
then
   echo "please define WP_IMPORT_DUMP"
   exit 1
fi

echo "preparing dump file"

INFILE=$WP_IMPORT_DUMP
TMPFILE=/tmp/tmp.dump
OUTFILE=/tmp/new.dump

echo "DROP DATABASE IF EXISTS $MYSQL_DATABASE;" > $OUTFILE
echo "CREATE DATABASE $MYSQL_DATABASE DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;" >> $OUTFILE
echo "USE $MYSQL_DATABASE;" >> $OUTFILE

cp $WP_IMPORT_DUMP $TMPFILE

sed -i -e 's/^CREATE DATABASE /-- CREATE DATABASE /g' $TMPFILE
sed -i -e 's/^USE /-- USE /g' $TMPFILE

sed -i 's/ENGINE=MyISAM/ENGINE=InnoDB/g' $TMPFILE

cat $TMPFILE >> $OUTFILE

echo "importing dump file into mysql"

mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST --default_character_set utf8 < $OUTFILE