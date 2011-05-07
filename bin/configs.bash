#!/usr/bin/env bash

set -e

source $(cd $(dirname $0) && pwd)/env.bash
source $__FILE__/site.bash

### These should be .gitignored;

FILES=(
	srv/dnsmasq/etc/hosts
	srv/dnsmasq/etc/dnsmasq.conf
)

### Generate Configs;

for i in "${FILES[@]}"; do
  base=${__FILE__}/../
  source=${base}$i.template
	target=${base}/$i

	eval "echo \"$(cat ${source})\"" > ${target}
done


exit 0
