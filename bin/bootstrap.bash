#!/usr/bin/env bash

set -e

source $(cd $(dirname $0) && pwd)/env.bash

### Configure Site;

echo -n "Domain:"
read DOMAIN
echo -n "PXE/DHCP Server IP:"
read PXE_HOST
echo -n "DHCP Range: (X.X.X.X,Y.Y.Y.Y)"
read DHCP_RANGE
echo -n "Ubuntu distro to build: (maverick, natty, etc)" 
# See http://archive.ubuntu.com/ubuntu/dists/ for a full list
read DISTRO

### Create site.bash;

cat >${__FILE__}/site.bash<<EOF
export DOMAIN=${DOMAIN}
export PXE_HOST=${PXE_HOST}
export DHCP_RANGE=${DHCP_RANGE}
export DHCP_INTERFACE=${DHCP_INTERFACE:-eth0}
export PROJECT_ROOT=${PROJECT_ROOT:-/opt}
export DISTRO=${DISTRO}
export ARCH=${ARCH:-amd64}
EOF

### Prepare system;

apt-get update
apt-get upgrade

apt-get install dnsmasq
apt-get install apt-cacher

SKIPDOWNLOAD=0

. site.bash

# If you've manually placed an extracted netboot.tar.gz in the boot directory, set SKIPDOWNLOAD = 1 above
if [ $SKIPDOWNLOAD != 1 ]; then
  wget http://archive.ubuntu.com/ubuntu/dists/$DISTRO/main/installer-amd64/current/images/netboot/netboot.tar.gz -O ${PROJECT_ROOT}/cede/boot/netboot.tar.gz
  if [ $? == 8 ]; then
    echo "I seem to have gotten a 404 trying to grab http://archive.ubuntu.com/ubuntu/dists/$DISTRO/main/installer-${ARCH}/current/images/netboot/netboot.tar.gz"
    echo "You'll want to find the correct netboot.tar.gz, place it in ${PROJECT_ROOT}/cede//boot, extract it, and set SKIPDOWNLOAD=1 in $0"
    echo "Quitting..."
    exit 1
  fi
fi

CURRENT=$( pwd )
cd $PROJECT_ROOT/cede/boot/ && tar -zxvf netboot.tar.gz && mv syslinux.cfg ubuntu-installer/${ARCH}/boot-screens/syslinux.cfg && rm -f netboot.tar.gz && cd $CURRENT

### Disable default dnsmasq, otherwise it conflicts with ours

sed -i 's/ENABLED=1/ENABLED=0/' /etc/default/dnsmasq
service dnsmasq stop

### Enable apt-cacher;

sed -i 's/\(AUTOSTART=\).*/\11/' /etc/default/apt-cacher
sed -i 's/# \(path_map.*\)/\1/' /etc/apt-cacher/apt-cacher.conf

service apt-cacher restart

### Finished;

echo
echo "INFO: Generate configs with $(dirname ${0})/configs.bash"


exit 0
