#!/bin/bash

# FUNCTION rabbitmqbroker SETUP SCRIPT
#
# reminder: this runs as sudo


apt-get install -y --force-yes rabbitmq-server

systemctl stop rabbitmq-server

rabbitmqctl add_user ${functions.rabbitmq.user} ${SECRET.rabbitmq.psw.user}
rabbitmqctl add_vhost ${functions.rabbitmq.vhost}

rabbitmqctl change_password guest ${SECRET.rabbitmq.psw.guest}

rabbitmqctl set_permissions -p ${functions.rabbitmq.vhost} ${functions.rabbitmq.user} ".*" ".*" ".*"
rabbitmqctl set_permissions -p ${functions.rabbitmq.vhost} guest ".*" ".*" ".*"

systemctl enable rabbitmq-server
systemctl restart rabbitmq-server

