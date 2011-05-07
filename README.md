# cede

> to give over, surrender or relinquish to the physical control of another.

## Usage

Clone this repo to /opt.  Now PXE boot your hosts after executing the following:

    $ cd /opt/cede
    $ ./bin/dnsmasq.bash start
    $ ./bin/webserver.bash start
    $ ./bin/bootstrap.bash
    $ ./bin/configs.bash

The preseed was modified by hand from:

    media/cdrom/preseed/ubuntu-server.seed

To generate a preseed from an existing install:

    $ debconf-get-selections --installer > file
    $ debconf-get-selections >> file

## Recipes

Created bash "recipes" to handle configuration of system roles.

* firewall.bash: Enables natting on from eth0 -> eth1.  Also, disables all but inbound port 22.

## TODO:

  * firewall.bash: Save iptables.
  * firewall.bash: Restore iptables on boot.
  * preseed: disable ssh root login.
  * preseed: create ubuntu user.
  * preseed: ubuntu user has sudo.
  * preseed: ubuntu user has pubkey.

On firewall update /etc/hosts (automate):

    $ cat srv/dnsmasq/dnsmasq.d/dhcp-hosts.paloalto | awk -F, '{print $2"\t"$3}' | sort -k 2 >> /etc/hosts
