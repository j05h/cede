#!/usr/bin/env bash

set -e

source $(cd $(dirname $0) && pwd)/env.bash

PID=${PID_HOME}/webserver.pid
DOC_ROOT=${__FILE__}/../var/www/ubuntu

case ${1} in
	"start")
		echo "INFO: Starting Python's SimpleHTTPServer."

		cd ${DOC_ROOT}

		nohup python -m SimpleHTTPServer &

		echo "${!}" > ${PID}
	;;

	"stop")
		echo "INFO: Stopping Python's SimpleHTTPServer."

		cat ${PID} |xargs kill
	;;

	*)
		echo "Usage: ${0} <start|stop>"
	;;
esac


exit 0
