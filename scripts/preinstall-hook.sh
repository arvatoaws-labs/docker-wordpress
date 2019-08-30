#!/bin/bash
set -e

/scripts/sleep.sh

/scripts/wait-for-mysql-root.sh

sleep 1

/scripts/create-mysql-database.sh

sleep 1

/scripts/create-mysql-user.sh

sleep 1

/scripts/wait-for-mysql-user.sh

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