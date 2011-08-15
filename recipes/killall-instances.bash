#!/usr/bin/env bash

instances=$( euca-describe-instances | grep INSTANCE | awk '{ print $2 }' )

for i in $instances; do
  echo $i && euca-terminate-instances $i
done
