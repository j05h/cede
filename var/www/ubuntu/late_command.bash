exec >/root/postinstall.log
exec 2>&1

mkdir -p /root/.ssh && chmod 0700 /root/.ssh
wget -O /root/.ssh/authorized_keys http://build-host/authorized_keys && chmod 0600 /root/.ssh/authorize
sed -i "s/ListenAddress 0.0.0.0/&\nListenAddress $(hostname -i)/" /etc/ssh/sshd_config
