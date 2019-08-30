#!/bin/bash
set -e

if [ "$SLEEP" = "" ]
then
  echo "starting immediately"
else
  echo "sleeping for $SLEEP seconds..."
  sleep $SLEEP
fi
