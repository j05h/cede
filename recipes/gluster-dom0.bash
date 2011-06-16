#!/usr/bin/env bash

set -ex

RAND=$[ 1 + $[ RANDOM % 2 ]]
GLUSTER_NFS_NODE=gluster${RAND}-nfs
GLUSTER_MOUNT=/data/g
GLUSTER_VOLUME=/gluster-dom0
GLUSTER_FSTAB="${GLUSTER_NFS_NODE}:${GLUSTER_VOLUME} ${GLUSTER_MOUNT} nfs nfsvers=3,_netdev 0 0"

### Install the prerequisites;

apt-get install nfs-common

### Mount gluster;

mkdir -p ${GLUSTER_MOUNT}
echo ${GLUSTER_FSTAB} >> /etc/fstab
mount ${GLUSTER_MOUNT}


exit 0
