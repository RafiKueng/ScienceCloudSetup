
NETWINT=`openstack network list -f value | grep net_internal | cut --delimiter " " --fields 1`
SNETINT=`openstack subnet list -f value | grep net_internal | cut --delimiter " " --fields 1`

NETWUZH=`openstack network list -f value | grep net_uzh | cut --delimiter " " --fields 1`
SNETUZH=`openstack subnet list -f value | grep net_uzh | cut --delimiter " " --fields 1`

NETWEXT=`openstack network list -f value | grep net_internet | cut --delimiter " " --fields 1`
SNETEXT=`openstack subnet list -f value | grep net_internet | cut --delimiter " " --fields 1`


# controller

IP="10.0.0.1"
echo " > creating ${IP} ${NAME}"
NAME="port.0.00.01 - controller @int"
openstack port create --network ${NETWINT} --fixed-ip subnet=${SNETINT},ip-address=${IP} "${NAME}"

IP="10.1.0.1"
echo " > creating ${IP} ${NAME}"
NAME="port.1.00.01 - controller @uzh"
openstack port create --network ${NETWUZH} --fixed-ip subnet=${SNETUZH},ip-address=${IP} "${NAME}"


# load balancer

IP="10.0.9.1"
NAME="port.0.09.01 - loadbalancer @int"
echo " > creating ${IP} ${NAME}"
openstack port create --network ${NETWINT} --fixed-ip subnet=${SNETINT},ip-address=${IP} "${NAME}"

IP="10.2.9.1"
NAME="port.2.09.01 - loadbalancer @ext"
echo " > creating ${IP} ${NAME}"
openstack port create --network ${NETWEXT} --fixed-ip subnet=${SNETEXT},ip-address=${IP} "${NAME}"


# webserver

for N in 1 2 3; do
    NN=$(printf "%02d" $N)

    IP="10.0.10.${N}"
    NAME="port.0.10.${NN} - webserver-${NN} @int"
    echo " > creating ${IP} ${NAME}"
    openstack port create --network ${NETWINT} --fixed-ip subnet=${SNETINT},ip-address=${IP} "${NAME}"
done


# appserver

for N in 1 2 3; do
    NN=$(printf "%02d" $N)

    IP="10.0.11.${N}"
    NAME="port.0.11.${NN} - appserver-${NN} @int"
    echo " > creating ${IP} ${NAME}"
    openstack port create --network ${NETWINT} --fixed-ip subnet=${SNETINT},ip-address=${IP} "${NAME}"
done


# staticserver

for N in 1 2 3; do
    NN=$(printf "%02d" $N)

    IP="10.0.12.${N}"
    NAME="port.0.12.${NN} - staticserver-${NN} @int"
    echo " > creating ${IP} ${NAME}"
    openstack port create --network ${NETWINT} --fixed-ip subnet=${SNETINT},ip-address=${IP} "${NAME}"
done



# dbserver

for N in 1; do
    NN=$(printf "%02d" $N)

    IP="10.0.20.${N}"
    NAME="port.0.20.${NN} - dbserver-${NN} @int"
    echo " > creating ${IP} ${NAME}"
    openstack port create --network ${NETWINT} --fixed-ip subnet=${SNETINT},ip-address=${IP} "${NAME}"
done


# broker

for N in 1; do
    NN=$(printf "%02d" $N)

    IP="10.0.30.${N}"
    NAME="port.0.30.${NN} - broker-${NN} @int"
    echo " > creating ${IP} ${NAME}"
    openstack port create --network ${NETWINT} --fixed-ip subnet=${SNETINT},ip-address=${IP} "${NAME}"
done


# worker nodes

for N in {1..16}; do
    NN=$(printf "%02d" $N)
    IP="10.0.99.${N}"
    NAME="port.0.99.${NN} - worker-${NN} @int"
    echo " > creating ${IP} ${NAME}"
    openstack port create --network ${NETWINT} --fixed-ip subnet=${SNETINT},ip-address=${IP} "${NAME}"
done














