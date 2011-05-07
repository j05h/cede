#!/usr/bin/env bash

set -e

ILO=${1}

if [ -z ${ILO} ]; then
	echo "Usage: ${0} <ilo>"

	exit 1
fi

echo "INFO: Server info from '${ILO}'."

ssh ${ILO} "show server info all"


exit 0
