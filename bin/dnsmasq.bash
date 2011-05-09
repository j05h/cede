#!/usr/bin/env bash

set -e

source $(cd $(dirname $0) && pwd)/env.bash

PID=${PID_HOME}/dnsmasq.pid
CONF=${__FILE__}/../srv/dnsmasq/etc/dnsmasq.conf
RESOLV_CONF=/etc/resolv.conf

case ${1} in
	"start")
		echo "INFO: Starting dnsmasq."

		sed -i "1i\
nameserver 127.0.0.1 ### Added by ${0};
" ${RESOLV_CONF}
		dnsmasq --pid-file=${PID} --conf-file=${CONF}
	;;

	"stop")
		echo "INFO: Stopping dnsmasq."

		sed -i "/nameserver 127.0.0.1/d" ${RESOLV_CONF}
		cat ${PID} |xargs kill
	;;

	"restart")
		${0} stop && ${0} start
	;;

	*)
		echo "Usage: ${0} <start|stop|restart>"
	;;
esac


exit 0
