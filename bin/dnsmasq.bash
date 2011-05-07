#!/usr/bin/env bash

set -e

source $(cd $(dirname $0) && pwd)/env.bash

PID=${PID_HOME}/dnsmasq.pid
CONF=${__FILE__}/../srv/dnsmasq/etc/dnsmasq.conf
HOSTS=/etc/hosts

case ${1} in
	"start")
		echo "INFO: Starting dnsmasq."

    cat - ${HOSTS} <<<"nameserver 127.0.0.1" > ${HOSTS}
		dnsmasq --pid-file=${PID} --conf-file=${CONF}
	;;

	"stop")
		echo "INFO: Stopping dnsmasq."

		sed -i "/nameserver 127.0.0.1/d" ${HOSTS}
		cat ${PID} |xargs kill
	;;

	"restart")
		echo "INFO: Restarting dnsmasq."

		${0} stop && ${0} start
	;;

	*)
		echo "Usage: ${0} <start|stop|restart>"
	;;
esac


exit 0
