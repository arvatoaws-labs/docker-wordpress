#!/bin/bash
set -e

cd /app

/scripts/sleep.sh

/scripts/wait-for-mysql.sh

echo "running wp cronjobs..."
wp cron event run --due-now