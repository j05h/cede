#!/usr/bin/env bash

apt-get -y update

apt-get -y install vlan

apt-get -y install nova-compute euca2ools unzip

service libvirt-bin restart
