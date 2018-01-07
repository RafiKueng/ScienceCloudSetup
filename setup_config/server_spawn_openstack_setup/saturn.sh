


HOSTNAME="${servers.saturn.host}"

HOSTID=`openstack server list -f value | grep "${HOSTNAME}" | cut --delimiter " " --fields 1`

if [ ! -z "$HOSTID" ]; then
    echo "host already exists, quitting"
    exit 1
else
    echo "host does not exists, we will set it up"
    exit 0
fi
