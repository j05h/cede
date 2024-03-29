#!/usr/bin/env bash

set -e

# Setup the OpenStack apt repo and required dependencies
apt-get -y install python-software-properties && add-apt-repository ppa:nova-core/trunk
apt-get -y update

# We should install NTP here, because every openstack machines needs it
apt-get install ntp
