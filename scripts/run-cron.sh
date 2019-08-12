#!/bin/bash
set -e

cd /app

/scripts/sleep.sh

/scripts/wait-for-mysql-user.sh

echo "running wp cronjobs..."
wp cron event run --due-now