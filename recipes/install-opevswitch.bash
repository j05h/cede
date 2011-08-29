#!/usr/bin/env bash

set -e

echo "Make sure you've removed the bridge mod"
echo "rmmod bridge"
echo "Continue? "
read cont
if [ $cont ne "y" ]; then
  exit 1
fi

url="http://openvswitch.org/releases/openvswitch-1.2.1.tar.gz"

mkdir -p ~/openvswitch
cd ~/openvswitch
wget $url
tar -zxvf openvswitch-1.2.1.tar.gz
cd openvswitch-1.2.1
./configure --with-linux=/lib/modules/`uname -r`/build && make && make install
insmod datapath/linux/openvswitch_mod.ko
insmod datapath/linux/brcompat_mod.ko

mkdir -p /usr/local/etc/openvswitch
ovsdb-tool create /usr/local/etc/openvswitch/conf.db vswitchd/vswitch.ovsschema

ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,manager_options --private-key=db:SSL,private_key --certificate=db:SSL,certificate --bootstrap-ca-cert=db:SSL,ca_cert --pidfile --detach
ovs-vsctl --no-wait init
ovs-vswitchd --pidfile --detach
ovs-brcompatd --pidfile --detach
