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

### Create site.bash;

cat >${__FILE__}/site.bash<<EOF
export DOMAIN=${DOMAIN}
export PXE_HOST=${PXE_HOST}
export DHCP_RANGE=${DHCP_RANGE}
export DHCP_INTERFACE=${DHCP_INTERFACE:-eth0}
export PROJECT_ROOT=${PROJECT_ROOT:-/opt}
EOF

### Prepare system;

apt-get update
apt-get upgrade

apt-get install dnsmasq
apt-get install apt-cacher

### Enable apt-cacher;

sed -i 's/\(AUTOSTART=\).*/\11/' /etc/default/apt-cacher
sed -i 's/# \(path_map.*\)/\1/' /etc/apt-cacher/apt-cacher.conf

service apt-cacher restart

### Finished;

echo
echo "INFO: Generate configs with $(dirname ${0})/configs.bash"


exit 0
