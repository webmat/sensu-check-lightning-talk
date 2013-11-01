#!/bin/bash

rand=$RANDOM
if [ $rand -gt 10000 ]; then
  echo "Ok: random number generated was high enough ($rand)"
  exit 0
else
  if [ $rand -gt 1000 ]; then
    echo Warning: random number generated was $rand
    exit 1
  else
    echo Critical: random number generated was $rand
    exit 2
  fi
fi

echo Unknown: How did I get here?
exit 3 # or higher
