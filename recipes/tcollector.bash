#!/usr/bin/env bash

# Make sure we have the right info
if [ -z $1 ]; then
  echo "You must provide the collector host to use"
  echo "$0 collect.example.com"
  exit
fi

# Read in the command line args
TSD_HOST=$1

# Set some paths
TCOL_BASE="/opt"
GIT_URL="https://github.com/stumbleupon/tcollector.git"
CHECKOUT_DIR=$( echo $GIT_URL | awk -F/ '{ print $NF }' | awk -F. '{ print $1 }' )
TCOLLECTOR_PATH=$TCOL_BASE/$CHECKOUT_DIR

# Check out the code and cd to the tcolletor directory
cd $TCOL_BASE
git clone $GIT_URL
cd $CHECKOUT_DIR

echo "description \"Tcollector agent\"
author \"Kevin Bringard <kbringard@att.com>\"

start on (local-filesystems and net-device-up IFACE!=lo)
stop on runlevel [016]

respawn

exec su -c \"env TSD_HOST=$TSD_HOST TCOLLECTOR_PATH=$TCOLLECTOR_PATH $TCOLLECTOR_PATH/startstop start\" root" >> /etc/init/tcollector.conf

start tcollector
