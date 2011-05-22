#!/usr/bin/env bash

# In order to generate our nova.conf we need to define a few variables
# If you wish to override these defaults, create a file called controller_env
#  in this directory and define your variables in there
# You should also set your nova username and password in that file
#  so it won't be overwritten by blank values when you update cede from github

if [ ! -f /etc/apt/sources.list.d/nova-core-trunk-maverick.list ]; then
  ./openstack-repo.bash
fi

my_ip=$( host $( hostname ) | awk '{ print $NF }' )
my_subnet=$( echo $my_ip | awk -F\. '{ print $1"."$2"."$3 }' )

sql_host="$my_ip"
nova_db="nova"
nova_user=""
nova_pass=""
glance_host="$my_ip"
public_interface="eth0"
vlan_interface="eth1"
nova_conf_tmpl="nova.conf.tmpl"

if [ -f controller_env ]; then
  . controller_env
fi

if [ -z $nova_user ] || [ -z $nova_pass ]; then
  echo "You must specify your nova username and password"
  echo "It's recommended that you do this in controller_env"
  exit 1
fi

apt-get -y install rabbitmq-server

apt-get -y install nova-api nova-objectstore nova-scheduler euca2ools unzip mysql-server

# Fill out our nova.conf with the appropriate values
cat $nova_conf_tmpl > nova.conf
sed -i "s/%USER%/$nova_user/g" nova.conf
sed -i "s/%PASSWORD%/$nova_pass/g" nova.conf
sed -i "s/%DBHOST%/$sql_host/g" nova.conf
sed -i "s/%DATABASE%/$nova_db/g" nova.conf
sed -i "s/%CONTROLLER%/$my_ip/g" nova.conf
sed -i "s/%VLANINTERFACE%/$vlan_interface/g" nova.conf
sed -i "s/%PUBLICINTERFACE%/$public_interface/g" nova.conf
sed -i "s/%GLANCE%/$glance_host/g" nova.conf
sed -i "s/%SUBNET%/$my_subnet/g" nova.conf

# Copy it into place
cp -f nova.conf /etc/nova/nova.conf

# We need to tell mysql to listen on all interfaces (not just localhost)
sed -i "s/= 127.0.0.1/= 0.0.0.0/" /etc/mysql/my.cnf
service mysql restart

echo "
create database $nova_db;
grant all on $nova_db.* to '$nova_user'@'localhost' identified by '$nova_pass';
grant all on $nova_db.* to '$nova_user'@'%' identified by '$nova_pass';" > nova_db.sql

echo "Creating the nova db and grants with mysql -u root -p < nova_db.sql"
mysql -u root -p < nova_db.sql

nova-manage db sync

if [ ! -f "/etc/dnsmasq.conf" ]; then
  touch /etc/dnsmasq.conf
fi
