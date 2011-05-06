__FILE__=$(cd $(dirname $0) && pwd)
PID_HOME=${__FILE__}/../var/run

if [ ! -d ${PID_HOME} ]; then
  echo "INFO: created ${PID_HOME}"

  mkdir -p ${PID_HOME}
fi
