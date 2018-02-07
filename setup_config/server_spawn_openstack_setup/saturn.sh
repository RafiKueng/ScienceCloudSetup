#!/bin/bash

${!insert_standard_functions}


HOSTNAME="${servers.saturn.host}"

FLAVOR="${servers.saturn.flavor}"
SECGRP="${servers.saturn.secgroup}"
IMAGE="${servers.image}"

NETWORK="${servers.saturn.networks.int.name}"
SHORTNWNAME="${servers.saturn.networks.int.short}"
IP="${servers.saturn.networks.int.ip}"

NETWORKUZH="${servers.saturn.networks.uzh.name}"

SSHKEYNAME="${servers.sshkeyname}"


### check if server already exists 

HOSTID=`get_openstack_id_of server ${HOSTNAME}`

if [ ! -z "$HOSTID" ]; then
    echo "host already exists, quitting"
    echo "we will not update!!"
    exit 0
else
    echo "host does not exists, we will set it up"
fi



FLAVORID=`get_openstack_id_of flavor "${FLAVOR}"`
SECGRPID=`get_openstack_id_of "security group" "${SECGRP}"`
IMAGEID=`get_openstack_id_of image "${IMAGE}"`

NETID=`get_openstack_id_of network "${NETWORK}"`
SUBNETID=`get_openstack_id_of subnet "${NETID}"`



ADDR=(${IP//./ })
IP0=${ADDR[0]}
IP1=${ADDR[1]}
IP2=${ADDR[2]}
IP3=${ADDR[3]}
IP00=$(printf "%01d" $IP0)
IP01=$(printf "%01d" $IP1)
IP02=$(printf "%02d" $IP2)
IP03=$(printf "%03d" $IP3)

PORTNAME="port-${IP01}.${IP02}.${IP03} ${HOSTNAME} @${SHORTNWNAME}"


PORTID=`get_openstack_id_of port "${PORTNAME}"`
if [ ! -z "$PORTID" ]; then
    echo "network port on INT already exists, skipping creation of port"
else
    echo "network port on INT does not yet exists, we will set it up"
    openstack port create                               \
        --network ${NETID}                              \
        --fixed-ip subnet=${SUBNETID},ip-address=${IP}  \
        "${PORTNAME}"
    PORTID=`get_openstack_id_of port "${IP}"`
fi


NETWIDUZH=`get_openstack_id_of network "${NETWORKUZH}"`
if [ -z "$NETWIDUZH" ]; then
    echo "cant find uzh-only network, aborting"
    exit 1
fi


openstack server create        \
    --image $IMAGEID                \
    --flavor $FLAVORID              \
    --security-group $SECGRPID      \
    --key-name "${SSHKEYNAME}"      \
    --nic net-id=$NETWIDUZH         \
    --nic port-id=$PORTID           \
    "${HOSTNAME}"
   
