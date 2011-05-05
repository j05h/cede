#!/usr/bin/env bash

set -e


case ${1} in
  "start")
    dnsmasq --conf-file=srv/dnsmasq/etc/dnsmasq.conf
  ;;

  "stop")
  ;;

  *)
  ;;
esac


exit 0
