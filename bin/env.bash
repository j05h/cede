__FILE__=$(cd $(dirname $0) && pwd)
PID_HOME=${__FILE__}/../var/run
LOG_HOME=${__FILE__}/../var/log

if [ ! -d ${PID_HOME} -o  ! -d ${LOG_HOME} ]; then
	mkdir -p ${PID_HOME} ${LOG_HOME}
fi
