#!/bin/bash

${!insert_standard_functions}


HOSTNAME="${servers.mimas.host}"

FLAVOR="${servers.mimas.flavor}"
SECGRP="${servers.mimas.secgroup}"
IMAGE="${servers.image}"

SSH_keyname="${servers.sshkeyname}"

NETW_int_name="${servers.mimas.networks.int.name}"
NETW_int_short="${servers.mimas.networks.int.short}"
NETW_int_ip="${servers.mimas.networks.int.ip}"

NETW_ext_name="${servers.mimas.networks.ext.name}"



### check if server already exists 

HOSTID=`get_openstack_id_of server ${HOSTNAME}`

if [ ! -z "$HOSTID" ]; then
    echo "host already exists, quitting"
    echo "we will not update!!"
    exit 0
else
    echo "host does not exists, we will set it up"
fi


ID_image=`get_openstack_id_of image "${IMAGE}"`
ID_flavor=`get_openstack_id_of flavor "${FLAVOR}"`
ID_secgrp=`get_openstack_id_of "security group" "${SECGRP}"`

ID_net_int=`get_openstack_id_of network "${NETW_int_name}"`
ID_snet_int=`get_openstack_id_of subnet "${ID_net_int}"`



ADDR=(${NETW_int_ip//./ })
IP0=${ADDR[0]}
IP1=${ADDR[1]}
IP2=${ADDR[2]}
IP3=${ADDR[3]}
IP00=$(printf "%01d" $IP0)
IP01=$(printf "%01d" $IP1)
IP02=$(printf "%02d" $IP2)
IP03=$(printf "%03d" $IP3)

PORTNAME="port-${IP01}.${IP02}.${IP03} ${HOSTNAME} @${SHORTNWNAME}"


ID_port_int=`get_openstack_id_of port "${PORTNAME}"`
if [ ! -z "$ID_port_int" ]; then
    echo "network port on INT already exists, skipping creation of port"
else
    echo "network port on INT does not yet exists, we will set it up"
    openstack port create                               \
        --network ${ID_net_int}                         \
        --fixed-ip subnet=${ID_snet_int},ip-address=${NETW_int_ip}  \
        "${PORTNAME}"
    ID_port_int=`get_openstack_id_of port "${NETW_int_ip}"`
fi


ID_net_ext=`get_openstack_id_of network "${NETW_ext_name}"`
if [ -z "$ID_net_ext" ]; then
    echo "can't find uzh-only network, aborting"
    exit 1
fi


openstack server create        \
    --image $ID_image               \
    --flavor $ID_flavor             \
    --security-group $ID_secgrp     \
    --key-name "${SSH_keyname}"     \
    --nic net-id=$ID_net_ext        \
    --nic port-id=$ID_port_int      \
    "${HOSTNAME}"
   