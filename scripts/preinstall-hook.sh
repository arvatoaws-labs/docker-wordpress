#!/bin/bash
set -e

/scripts/sleep.sh

/scripts/wait-for-mysql.sh

/scripts/create-mysql-database.sh

sleep 1

/scripts/create-mysql-user.sh

sleep 1

/scripts/install-wp-core.sh

sleep 1

/scripts/verify-wp-core-checksums.sh

sleep 1

/scripts/update-wp-core-database.sh

sleep 1

/scripts/update-wp-admin-user.sh

sleep 1

/scripts/activate-wp-plugins.sh