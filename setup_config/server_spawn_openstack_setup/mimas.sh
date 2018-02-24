#!/bin/bash

${!insert_standard_functions}


HOSTNAME="${servers.mimas.host}"

FLAVOR="${servers.mimas.flavor}"
SECGRP="${servers.mimas.secgroup}"
IMAGE="${servers.image}"

SSH_keyname="${servers.sshkeyname}"


# === check if server already exists ==========================================

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


# === create port on INT network ==============================================

NETW_int_name="${servers.mimas.networks.int.name}"
NETW_int_short="${servers.mimas.networks.int.short}"
NETW_int_ip="${servers.mimas.networks.int.ip}"

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


ID_net_int=`get_openstack_id_of network "${NETW_int_name}"`
ID_snet_int=`get_openstack_id_of subnet "${ID_net_int}"`
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



# === create port on public network ===========================================

NETW_ext_name="${servers.mimas.networks.ext.name}"
NETW_ext_ip="${servers.mimas.networks.ext.ip}"

ADDR=(${NETW_ext_ip//./ })
IP0=${ADDR[0]}
IP1=${ADDR[1]}
IP2=${ADDR[2]}
IP3=${ADDR[3]}
IP00=$(printf "%01d" $IP0)
IP01=$(printf "%01d" $IP1)
IP02=$(printf "%02d" $IP2)
IP03=$(printf "%03d" $IP3)

PORTNAME="port-${IP01}.${IP02}.${IP03} ${HOSTNAME} @${SHORTNWNAME}"

ID_net_ext=`get_openstack_id_of network "${NETW_ext_name}"`
ID_snet_ext=`get_openstack_id_of subnet "${ID_net_ext}"`
ID_port_ext=`get_openstack_id_of port "${PORTNAME}"`

if [ ! -z "$ID_port_ext" ]; then
    echo "network port on EXT already exists, skipping creation of port"
else
    echo "network port on EXT does not yet exists, we will set it up"
    openstack port create         \
        --network ${ID_net_ext}   \
        --fixed-ip subnet=${ID_snet_ext},ip-address=${NETW_ext_ip}  \
        "${PORTNAME}"
    ID_port_int=`get_openstack_id_of port "${NETW_ext_ip}"`
fi


# === create the init script ==================================================
userdata_tmpfile=$(mktemp)

echo "creating userdata file: $userdata_tmpfile"

cat <<EOT > $userdata_tmpfile
#!/bin/bash

echo "${connection_settings.sshkey1}" >> /home/${connection_settings.user}/.ssh/authorized_keys
echo "${connection_settings.sshkey2}" >> /home/${connection_settings.user}/.ssh/authorized_keys
echo "${connection_settings.sshkey3}" >> /home/${connection_settings.user}/.ssh/authorized_keys
EOT





# === CREATE THE INSTANCE =====================================================

openstack server create        \
    --image $ID_image               \
    --flavor $ID_flavor             \
    --security-group $ID_secgrp     \
    --key-name "${SSH_keyname}"     \
    --nic port-id=$ID_port_ext      \
    --nic port-id=$ID_port_int      \
    --user-data=$userdata_tmpfile   \
    "${HOSTNAME}"
   
rm $userdata_tmpfile
