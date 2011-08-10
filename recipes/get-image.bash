#/usr/bin/env bash

if [ -z $1 ]; then
  r="maverick"
else 
  r=$1
fi

mkdir -p ~/images/$r
cd ~/images/$r
image="$r-server-cloudimg-amd64.tar.gz"
wget http://uec-images.ubuntu.com/$r/current/$image
# wget http://uec-images.ubuntu.com/$r/current/$r-server-uec-amd64.tar.gz

tar -zxvf $image
