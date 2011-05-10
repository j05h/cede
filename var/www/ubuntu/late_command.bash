set -ex

exec >/root/postinstall.log
exec 2>&1

IP=$(host $(hostname -f) |awk '{print $NF}')

mkdir /root/.ssh && chmod 0700 /root/.ssh
wget -O /root/.ssh/authorized_keys http://build-host/authorized_keys && chmod 0600 /root/.ssh/authorized_keys
sed -i "s/ListenAddress 0.0.0.0/&\nListenAddress ${IP}/" /etc/ssh/sshd_config
