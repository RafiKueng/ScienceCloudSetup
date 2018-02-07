#!/bin/bash

#
# Define the ip adresses and ranges of the machines
# 
# The first two aa.bb define the network to use, internal, university or external
# SUBIP_XXX defines the third octed of the IP address: aa.bb.XX.dd
# and the last one specifies the machine..



echo "DEFINING IP RANGES/ADRESSES"

# prefix for the ip
PFX_INT="10.0"
PFX_UZH="10.1"
PFX_EXT="10.2"


# CONTROLLER AND ADMIN AREA
###############################################################################

# controller
# DONT ADD MULTIPLE
SUBIP_CONTROLLER="0"
N_CONTROLLER=1


# loadbalancer
# DONT ADD MULTIPLE
SUBIP_LOADBALANCER="1"
N_LOADBALANCER=1


# DATABASES
###############################################################################

# CouchDBserver
SUBIP_COUCHDBSERVER="2"
N_COUCHDBSERVER=1

# MariaDBserver
#
# we don't use one currently 
# SUBIP_MARIADBSERVER="3"
# N_MARIADBSERVER=1


# WEBSERVERS
###############################################################################

# WebServer
SUBIP_WEBSERVER="5"
N_WEBSERVER=1

# StaticWebServer
SUBIP_STATICSERVER="6"
N_STATICSERVER=1


# RabbitMQ Broker
SUBIP_RABBITMQBROKER="9"
N_RABBITMQBROKER=1




# SpL APPLICATION - 1X
###############################################################################

# SPL ProxyServer
SUBIP_SPL_PROXY="10"
N_SPL_PROXY=1

# SPL ApplicationServer
SUBIP_SPL_APPSERVER="11"
N_SPL_APPSERVER=1

# SPL MediaProxy
SUBIP_SPL_MEDIAPROXY="12"
N_SPL_MEDIAPROXY=1

# SPL MediaServer
SUBIP_SPL_MEDIASERVER="13"
N_SPL_MEDIASERVER=1

# SPL WorkerNodes
SUBIP_SPL_WORKERNODES="19"
N_SPL_WORKERNODES=16




