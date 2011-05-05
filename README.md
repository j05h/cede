# cede

> to give over, surrender or relinquish to the physical control of another.

## Usage

PXE boot your hosts after executing the following:

    $ ./bin/dnsmasq.bash start
    $ ./bin/webserver.bash start

The preseed was modified by hand from the media/cdrom/preseed/ubuntu-server.seed

To generate a preseed from an existing install:

    $ debconf-get-selections --installer > file
    $ debconf-get-selections >> file

## TODO

* Fix preseed (still prompting)
* dnsmasq has hardcoded mac addrs.
* Add cookbooks for compute, network, firewall nodes.
