#!/bin/bash

${!insert_standard_functions}


NETW_int_name="${networks.internal.name}"
SNET_int_name="sub${networks.internal.name}"


echo "Debug info: using interpreter: `which openstack`"



################################################################################
echo "--- setup network -------------------------------"


NETWORKID=`get_openstack_id_of network ${NETW_int_name}`
if [ ! -z "$NETWORKID" ]; then
    echo "network already, skipping"
else
    openstack network create ${NETW_int_name}
fi

NETWORKID=`get_openstack_id_of network ${NETW_int_name}`



################################################################################
echo "--- setup subnet for INT -------------------------------"


SUBNETID=`get_openstack_id_of subnet ${SNET_int_name}`

if [ ! -z "$SUBNETID" ]; then
    echo "subnet already, skipping"
else
    openstack subnet create ${SNET_int_name}   \
        --network ${NETWORKID}              \
        --subnet-range "${networks.internal.iprange}${networks.internal.sn_pfx}" \
        --dhcp                              \
        --allocation-pool start=${networks.internal.pool.start},end=${networks.internal.pool.end}  \
        --gateway=${networks.internal.gateway}                      \
        
    openstack subnet set ${SNET_int_name}      \
        --no-dns-nameservers                \
#        --no-allocation-pool                \

        
fi



################################################################################
echo "--- setup network extern ------------------------------"


NETW_ext_name="${networks.external.name}"
SNET_ext_name="sub${networks.external.name}"


ID_net_ext=`get_openstack_id_of network "${NETW_ext_name}"`
if [ ! -z "$ID_net_ext" ]; then
    echo "network already, skipping"
else
    openstack network create "${NETW_ext_name}"
fi

ID_net_ext=`get_openstack_id_of network "${NETW_ext_name}"`



################################################################################
echo "--- setup subnet of ext netw -------------------------------"


ID_snet_ext=`get_openstack_id_of subnet ${SNET_ext_name}`

if [ ! -z "$ID_snet_ext" ]; then
    echo "subnet already, skipping"
else
    openstack subnet create ${SNET_ext_name}   \
        --network ${ID_net_ext}              \
        --subnet-range "${networks.external.iprange}${networks.external.sn_pfx}" \
        --dhcp                              \
        --allocation-pool start=${networks.external.pool.start},end=${networks.external.pool.end}  \
        --gateway=${networks.external.gateway}  \
        
    openstack subnet set ${SNET_ext_name}      \
        --no-dns-nameservers
#        --no-allocation-pool                \

fi


################################################################################
echo "--- setup network router ------------------------------------------------"


ID_net=`get_openstack_id_of network "${routers.router_ext.fromNet.name}"`
ID_router=`get_openstack_id_of router "${routers.router_ext.name}"`

if [ -z "$ID_router" ]; then
    echo "creating router"
    openstack router create ${routers.router_ext.name}
else
    echo "router already exists"
fi

openstack router set --external-gateway "${ID_net}" ${routers.router_ext.name}
openstack router add subnet ${routers.router_ext.name} "sub${routers.router_ext.toNet.name}"




################################################################################
echo "--- aquire floating ip --------------------------------------------------"

# there is only one floating ip, so get it
ID_floatingip=`get_openstack_id_of "floating ip"`

if [ -z "$ID_floatingip" ]; then
    openstack floating ip create ${networks.public.name}
    ID_floatingip=`get_openstack_id_of "floating ip"`
    echo "floating ip aquired"
else
    echo "floating ip already exists"
fi





