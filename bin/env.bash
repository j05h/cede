__FILE__=$(cd $(dirname $0) && pwd)
PID_HOME=${__FILE__}/../var/run

# [ ! -d ${PID_HOME} ] && exec mkdir -p ${PID_HOME} && exit 0
