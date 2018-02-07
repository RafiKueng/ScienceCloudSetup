#!/bin/bash

#
# This script creates the network ports later to attach to to machines
#
# can be run multiple times, since already existing ports will not been regenerated
#



# load central ip settings
. ../settings/ips.sh
. ../settings/networks.sh



create_port () {
    local IP=$1

    local ADDR=(${IP//./ })
    local IP0=${ADDR[0]}
    local IP1=${ADDR[1]}
    local IP2=${ADDR[2]}
    local IP3=${ADDR[3]}
    local IP00=$(printf "%01d" $IP0)
    local IP01=$(printf "%01d" $IP1)
    local IP02=$(printf "%02d" $IP2)
    local IP03=$(printf "%03d" $IP3)
    local NETNAME=${3:4:3}

    local NAME="port-${IP01}.${IP02}.${IP03} $2 @${NETNAME}"

    declare -a NETS=("${!3}")
    local NET=${NETS[0]}
    local SNET=${NETS[1]}

    local T=$'\t'
    
    echo " > creating IP:${IP} $T named: ${NAME} $T in: ${NET:0:6} / ${SNET:0:6}"
    openstack port create --network ${NET} --fixed-ip subnet=${SNET},ip-address=${IP} "${NAME}"
}


echo "CREATE NETWORK PORTS"


# CONTROLLER AND ADMIN AREA
###############################################################################

# controller
create_port "${PFX_INT}.${SUBIP_CONTROLLER}.1" "controller" NET_INT[@]
create_port "${PFX_UZH}.${SUBIP_CONTROLLER}.1" "controller" NET_UZH[@]


# load balancer
create_port "${PFX_INT}.${SUBIP_LOADBALANCER}.1" "loadbalancer" NET_INT[@]
create_port "${PFX_EXT}.${SUBIP_LOADBALANCER}.1" "loadbalancer" NET_EXT[@]


# DATABASES
###############################################################################

# CouchDBserver
for ((N=1;N<=N_COUCHDBSERVER;++N)); do
    NN=$(printf "%02d" $N)
    create_port "${PFX_INT}.${SUBIP_COUCHDBSERVER}.${N}" "couchdbserver-${NN}" NET_INT[@]
done


# MariaDBserver
# for ((N=1;N<=N_MARIADBSERVER;++N)); do
#     NN=$(printf "%02d" $N)
#     create_port "${PFX_INT}.${SUBIP_MARIADBSERVER}.${N}" "mariadbserver-${NN}" NET_INT[@]
# done

# WEBSERVERS
###############################################################################

# WebServer
for ((N=1;N<=N_WEBSERVER;++N)); do
    NN=$(printf "%02d" $N)
    create_port "${PFX_INT}.${SUBIP_WEBSERVER}.${N}" "webserver-${NN}" NET_INT[@]
done


# StaticServer
for ((N=1;N<=N_STATICSERVER;++N)); do
    NN=$(printf "%02d" $N)
    create_port "${PFX_INT}.${SUBIP_STATICSERVER}.${N}" "staticserver-${NN}" NET_INT[@]
done


# RabbitMQ Broker
for ((N=1;N<=N_RABBITMQBROKER;++N)); do
    NN=$(printf "%02d" $N)
    create_port "${PFX_INT}.${SUBIP_RABBITMQBROKER}.${N}" "rabbitmqbroker-${NN}" NET_INT[@]
done



# SpL APPLICATION - 1X
###############################################################################

# SPL ProxyServer
for ((N=1;N<=N_SPL_PROXY;++N)); do
    NN=$(printf "%02d" $N)
    create_port "${PFX_INT}.${SUBIP_SPL_PROXY}.${N}" "spl-proxy-${NN}" NET_INT[@]
done



# SPL ApplicationServer
for ((N=1;N<=N_SPL_PROXY;++N)); do
    NN=$(printf "%02d" $N)
    create_port "${PFX_INT}.${SUBIP_SPL_APPSERVER}.${N}" "spl-appserver-${NN}" NET_INT[@]
done

# SPL MediaProxy
for ((N=1;N<=N_SPL_MEDIAPROXY;++N)); do
    NN=$(printf "%02d" $N)
    create_port "${PFX_INT}.${SUBIP_SPL_MEDIAPROXY}.${N}" "spl-mediaproxy-${NN}" NET_INT[@]
done

# SPL MediaServer
for ((N=1;N<=N_SPL_MEDIASERVER;++N)); do
    NN=$(printf "%02d" $N)
    create_port "${PFX_INT}.${SUBIP_SPL_MEDIASERVER}.${N}" "spl-mediaserver-${NN}" NET_INT[@]
done

# SPL WorkerNodes
for ((N=1;N<=N_SPL_WORKERNODES;++N)); do
    NN=$(printf "%02d" $N)
    create_port "${PFX_INT}.${SUBIP_SPL_WORKERNODES}.${N}" "spl-workernode-${NN}" NET_INT[@]
done



# OtherApp APPLICATION - 2X
###############################################################################

#
# none yet available, write one!
#









