#!/usr/bin/env bash

set -e

ILO=${1}
BLADES=${2}

case ${3} in
	"net")
		echo "INFO: Netbooting blade(s) '${BLADES}' on ${ILO}."

		ssh ${ILO} "reboot server ${BLADES} pxe"
	;;

	*)
		echo "Usage: ${0} <ilo> <blades (eg 1,2,3)> <net>"
	;;
esac


exit 0
