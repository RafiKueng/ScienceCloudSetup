


HOSTNAME="${machines.saturn.host}"

HOSTID=`openstack server list -f value | grep "${HOSTNAME}" | cut --delimiter " " --fields 1`

if [[ ! -z "$HOSTID" ]]; then
    echo "host already exists, quitting"
    exit 0
else
    echo "host does not exists, we will set it up"
fi
