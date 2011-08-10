#!/usr/bin/env bash

set -e

args=$( getopt :u:d:p: $* )

usage() {
  echo "USAGE: $0 [options]
  -p  Project name
  -u  User to set as the admin (defaults to root)
  -d  Description of the project
  
  Example:
  $0 -p test -u root -d "This is a test project owned by root"
  "
  exit 1
}

if [ -z $1 ]; then
  usage
fi

for i; do
  case "$i" in
    -p) shift; project=$1; shift;;
    -u) shift; user=$1; shift;;
    -d) shift; description=$1; shift;;
  esac
done

nova_manage=$( which nova-manage )

if [ -z $user ]; then
  user="root"
fi


set +e

$nova_manage user list | grep ${user} > /dev/null

if [ $? == 1 ]; then
  echo "You need to create the user ${user} and make them an admin"
  echo "This should work: $nova_manage user admin --name=\"${user}\""
  exit 1
fi

set -e

echo "$nova_manage project create --project=\"${project}\" --user=\"${user}\" --desc=\"${description}\"" | sh

mkdir -p ~/creds/$project/root
cd ~/creds/$project/root
echo "$nova_manage project zipfile --project=\"${project}\" --user=\"${user}\" --file=\"${user}-${project}.zip\"" | sh
unzip ${user}-${project}.zip
. novarc

image_id=$( euca-describe-images | grep machine | tail -1 | awk '{ print $2 }' )
if [ -z $image_id ]; then
  echo "I couldn't find any images, have you uploaded any?"
  exit 1
fi

euca-run-instances $image_id
