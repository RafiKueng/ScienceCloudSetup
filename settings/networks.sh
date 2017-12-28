#!/bin/bash

#
# This script sets the IDs of the networks already created in openstack gui
#

echo "GET NETWORK NAMES"
# get already created networks

echo " > internal network"
NETWINT=`openstack network list -f value | grep net_internal | cut --delimiter " " --fields 1`
SNETINT=`openstack subnet list -f value | grep net_internal | cut --delimiter " " --fields 1`
NET_INT=(${NETWINT} ${SNETINT})

echo " > uzh network"
NETWUZH=`openstack network list -f value | grep net_uzh | cut --delimiter " " --fields 1`
SNETUZH=`openstack subnet list -f value | grep net_uzh | cut --delimiter " " --fields 1`
NET_UZH=(${NETWUZH} ${SNETUZH})

echo " > external network"
NETWEXT=`openstack network list -f value | grep net_internet | cut --delimiter " " --fields 1`
SNETEXT=`openstack subnet list -f value | grep net_internet | cut --delimiter " " --fields 1`
NET_EXT=(${NETWEXT} ${SNETEXT})
