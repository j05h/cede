#!/usr/bin/bash

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

nova_manage = $( which nova-manage )

if [ -z $user ]; then
  user="root"
fi

$nova_manage project create --project="${project}" --user="${user}" --desc="${description}"

mkdir -p ~/creds/$project/root
cd ~/creds/$project/root
$nova_manage project zipfile --project="${project}" --user="${user}" --file="${user}-${project}.zip"
unzip nova.zip
. novarc
euca-run-instances $( euca-describe-images | grep machine | tail -1 | awk '{ print $2 }' )
