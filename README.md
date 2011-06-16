# cede

> to give over, surrender or relinquish to the physical control of another.

## Usage

Install Git.

    $ apt-get install git

Clone this repo to /opt.  Now PXE boot your hosts after executing the following:

    $ cd /opt/cede
    $ ./bin/bootstrap.bash
    $ ./bin/configs.bash
    $ ./bin/dnsmasq.bash start
    $ ./bin/webserver.bash start

The preseed was modified by hand from:

    media/cdrom/preseed/ubuntu-server.seed

To generate a preseed from an existing install:

    $ debconf-get-selections --installer > file
    $ debconf-get-selections >> file

## Recipes

Created bash "recipes" to handle configuration of system roles.

* firewall.bash: Enables natting on from eth0 -> eth1.  Also, disables all but inbound SSH.
