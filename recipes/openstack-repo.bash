#!/usr/bin/env bash

# Setup the OpenStack apt repo and required dependencies
apt-get -y install python-software-properties
add-apt-repository ppa:nova-core/trunk
apt-get -y update
