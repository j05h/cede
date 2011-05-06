#!/usr/bin/env bash

set -e

apt-get update
apt-get upgrade

apt-get install dnsmasq
apt-get install apt-cacher


exit 0
