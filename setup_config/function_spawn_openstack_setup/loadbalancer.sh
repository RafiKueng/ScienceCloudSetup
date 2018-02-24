#!/bin/bash

#
# sets up the static ip and assignes it
#

${!insert_standard_functions}



################################################################################
echo "--- assign public floating ip ------------------------------------------"


ID_floatingip=`get_openstack_id_of "floating ip" ""`

if [ -z "$ID_floatingip" ]; then
    echo "ERROR: no floating ip available"
    exit 1
else
    echo "floating ip found"
fi


machineip="${functions.loadbalancer.networks.ext.ip}"
ID_port=`get_openstack_id_of port ${machineip}`

if [ -z "$ID_port" ]; then
    echo "ERROR, cannot find port on public net"
    exit 1
else
    echo "port found"
fi

openstack floating ip set --port ${ID_port} ${ID_floatingip}




