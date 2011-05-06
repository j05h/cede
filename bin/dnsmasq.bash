#!/usr/bin/env bash

set -e

source $(cd $(dirname $0) && pwd)/env.bash

PID=${PID_HOME}/dnsmasq.pid
CONF=${__FILE__}/../srv/dnsmasq/etc/dnsmasq.conf

case ${1} in
  "start")
    echo "INFO: Starting dnsmasq."

    dnsmasq --pid-file=${PID} --conf-file=${CONF}
  ;;

  "stop")
    echo "INFO: Stopping dnsmasq."

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
