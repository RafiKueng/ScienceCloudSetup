

NAME=${functions.basiccontroller.host}

echo "inside basiccontroller.sh yay ${functions.webserver.networks.ext.ip}"
openstack server list

NETWINT=`openstack network list -f value | grep net_internal | cut --delimiter " " --fields 1`
SNETINT=`openstack subnet list -f value | grep net_internal | cut --delimiter " " --fields 1`

echo $NETWINT
