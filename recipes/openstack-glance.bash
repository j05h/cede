#!/usr/bin/env bash

if [ ! -f /etc/apt/sources.list.d/nova-core-trunk-maverick.list ]; then
  ./openstack-repo.bash
fi

my_ip=$( host $( hostname ) | awk '{ print $NF }' )

glance_user=""
glance_pass=""
glance_db="glance"
db_host="$my_ip"

if [ -f glance_env ]; then
  . glance_env
fi

if [ -z $glance_user ] || [ -z $glance_pass ]; then
  echo "You must specify a glance_user and glance_pass"
  echo "It is recommended you do this in the file glance_env"
  exit 1
fi

apt-get -y install euca2ools unzip glance

sed -i "s/\(sql_connection\).*/#\1\nsql_connection = mysql:\/\/$glance_user:$glance_pass@$db_host\/$glance_db/" /etc/glance/glance.conf

echo "
create database $glance_db;
grant all on $glance_db.* to '$glance_user'@'localhost' identified by '$glance_pass';
grant all on $glance_db.* to '$glance_user'@'%' identified by '$glance_pass';" > glance_db.sql

echo "Creating the glance db and grants with mysql -u root -p < glance_db.sql"
mysql -u root -p < glance_db.sql

glance-manage db_sync
glance-control all restart
