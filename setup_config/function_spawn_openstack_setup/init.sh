#!/bin/bash


NETWORKNAME="${networks.internal.name}"
SUBNETNAME="sub${networks.internal.name}"
IPRANGE="${networks.internal.iprange}${networks.internal.sn_pfx}"
# in the 10.0.0.0/16 notation
POOLSTART=${networks.internal.pool_start}
POOLEND=${networks.internal.pool_end}

function get_openstack_id_of {
    openstack $1 list -f value | grep "$2" | cut --delimiter " " --fields 1
}


echo "Debug info: using interpreter: `which openstack`"


echo "--- setup network -------------------------------"

NETWORKID=`get_openstack_id_of network ${NETWORKNAME}`
if [ ! -z "$NETWORKID" ]; then
    echo "network already, skipping"
else
    openstack network create ${NETWORKNAME}
fi

NETWORKID=`get_openstack_id_of network ${NETWORKNAME}`



echo "--- setup subnet -------------------------------"

SUBNETID=`get_openstack_id_of subnet ${SUBNETNAME}`

if [ ! -z "$SUBNETID" ]; then
    echo "subnet already, skipping"
else
    openstack subnet create ${SUBNETNAME}   \
        --network ${NETWORKID}              \
        --subnet-range ${IPRANGE}           \
        --dhcp                              \
        --allocation-pool start=${POOLSTART},end=${POOLEND}  \
        --gateway=None                      \
        
    openstack subnet set ${SUBNETNAME}      \
        --no-allocation-pool                \
        --no-dns-nameservers                \

        
fi

    

    
