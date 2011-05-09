#!/usr/bin/env bash

set -e

source $(cd $(dirname $0) && pwd)/env.bash

PID=${PID_HOME}/webserver.pid
DOC_ROOT=${__FILE__}/../var/www/ubuntu
PORT="80"

case ${1} in
	"start")
		echo "INFO: Starting Python's SimpleHTTPServer."

		cd ${DOC_ROOT}
		python -m SimpleHTTPServer ${PORT} > ${LOG_HOME}/access.log 2>&1 </dev/null &
		echo "${!}" > ${PID}
	;;

	"stop")
		echo "INFO: Stopping Python's SimpleHTTPServer."

		cat ${PID} |xargs kill
	;;
	"restart")
		$0 stop && $0 start
	;;

	*)
		echo "Usage: ${0} <start|stop|restart>"
	;;
esac


exit 0
