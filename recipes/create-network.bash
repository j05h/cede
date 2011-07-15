#!/usr/bin/env bash

set -e

args=$( getopt :c:n:i:v:d: $* )

mysql_user="nova"

if [ -f .creds ]; then
  source .creds
else
  echo "You need to put your mysql_pass in .creds"
  echo "The following should work: echo \"mysql_pass='p@ss'\" > .creds"
  exit
fi

usage() {
  echo "USAGE: $0 [options]
  -c  CIDR block to allocate network(s) into
  -n  Number of networks to create
  -i  IPs to allocate per network
  -v  VLAN to assign (defaults to id + 9)
  -d  VLAN device (which interface do we vlan tag on)

  Example:
  $0 -c 10.4.1.0/24 -n 1 -i 256 -v 172 -d eth1
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
    -v) shift; vlan=$1; shift;;
    -d) shift; device=$1; shift;;
  esac
done

nova_manage=$( which nova-manage )
# nova_manage="nova-manage"

a=$( echo $cidr | awk -F. '{ print $2 }' )
b=$( echo $cidr | awk -F. '{ print $3 }' )

# echo "A: $a, B: $b"

bridge="br_${a}_${b}"


# vlan is id + 9 unless it was specified with -v
if [ -z $vlan ]; then
  id=$( echo "select id from networks order by id desc limit 1" > $$.sql && mysql -u nova --password=${mysql_pass} nova < $$.sql | tail -1  && rm -f $$.sql ) && id=$(( $id + 1 ))
  vlan=$(( id + 9 ))
fi

name="vlan${vlan}"

# echo "$nova_manage network create $name $cidr $networks $ips $vlan 0 0 0 0 $device"

echo "$nova_manage network create $name $cidr $networks $ips $vlan 0 0 0 0 $device" | sh

echo "set @id = ( select id from networks order by id desc limit 1 ); update networks set bridge = '$bridge' where id = @id; update fixed_ips set reserved = 1 where network_id = @id and address regexp '(\\.255$)';" > /tmp/$$.sql

mysql -u $mysql_user --password="$mysql_pass" nova < /tmp/$$.sql