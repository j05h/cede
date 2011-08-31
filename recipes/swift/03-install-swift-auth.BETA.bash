#!/usr/bin/env bash

. .env

apt-get -y install swift-auth


cat >/etc/swift/auth-server.conf <<EOF
[DEFAULT]
cert_file = /etc/swift/cert.crt
key_file = /etc/swift/cert.key
user = swift
[pipeline:main]
pipeline = auth-server
[app:auth-server]
use = egg:swift#auth
default_cluster_url = https://$zone1_ip:8080/v1 

# Highly recommended to change this key to something else!
super_admin_key = devauth
EOF

# Start the auth service
swift-init auth start

# Make sure the auth.db is owned by swift and not root
chown swift:swift /etc/swift/auth.db

# And retart for good measure
swift-init auth restart
