set -ex

exec >/root/postinstall.log
exec 2>&1

### add root's keys;

mkdir /root/.ssh && chmod 0700 /root/.ssh
wget -O /root/.ssh/authorized_keys http://build-host/authorized_keys && chmod 0600 /root/.ssh/authorized_keys

### ssh only listens on management interface;

IP=$(host $(hostname -f) |awk '{print $NF}')
sed -i "s/ListenAddress 0.0.0.0/&\nListenAddress ${IP}/" /etc/ssh/sshd_config

### ssh doesn't always start - make it so;

sed -i 's/start on filesystem/start on (filesystem and net-device-up IFACE=eth0)/' /etc/init/ssh.conf
