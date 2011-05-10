#!/usr/bin/env bash

r="maverick"
mkdir -p images/$r
wget http://uec-images.ubuntu.com/$r/current/$r-server-uec-amd64.tar.gz

cd images/$r
tar -zxvf $r-server-uec-amd64.tar.gz
