#!/usr/bin/env bash

set -e

args=$( getopt :c:n:i:p: $* )

mysql_user="nova"

usage() {
  echo "USAGE: $0 [options]
  -c  CIDR block to allocate network(s) into
  -n  Number of networks to create
  -i  IPs to allocate per network
  -p  Project to create

  Example:
  $0 -c 10.4.1.0/24 -n 1 -i 256 -p project
  "
  exit 1
}

if [ -z $1 ]; then
  usage
fi

for i; do
  case "$i" in
    -c) shift; cidr=$1; shift;;
    -n) shift; networks=$1; shift;;
    -i) shift; ips=$1; shift;;
    -p) shift; project=$1; shift;;
  esac
done


nova_manage=$( which nova-manage )
# nova_manage="nova-manage"

a=$( echo $cidr | awk -F. '{ print $2 }' )
b=$( echo $cidr | awk -F. '{ print $3 }' )

# echo "A: $a, B: $b"

bridge="br_${a}_${b}"
# vlan is id + 10 - 1

echo "$nova_manage network create $cidr $networks $ips" | sh

echo "set @id = ( select id from networks order by id desc limit 1 ); update networks set bridge = '$bridge' where id = @id; update networks set vlan = (id + 10 - 1) where id = @id; update fixed_ips set reserved = 1 where network_id = @id and address regexp '(\\.255$)';" > /tmp/$$.sql

mysql -u $mysql_user -p $mysq_pass nova < /tmp/$$.sql

echo "$nova_manage project create $project root" | sh

mkdir -p ~/creds/$project/root
cd ~/creds/$project/root
$nova_manage project zipfile $project root
unzip nova.zip
. novarc
euca-run-instances $( euca-describe-images | grep machine | tail -1 | awk '{ print $2 }' )
