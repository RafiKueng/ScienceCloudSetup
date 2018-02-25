#!/bin/bash

# FUNCTION LOADBALANCER SETUP SCRIPT
#
# reminder: this runs as sudo


# apt install -y nginx

echo "deb https://apache.bintray.com/couchdb-deb stretch main" \
    | tee /etc/apt/sources.list.d/couchdb.list

curl -L https://couchdb.apache.org/repo/bintray-pubkey.asc \
    | apt-key add -
    
apt update

COUCHDB_PASSWORD=${SECRET.couchdb.adminpsw}
echo "couchdb couchdb/mode select standalone
couchdb couchdb/mode seen true
couchdb couchdb/bindaddress string ${functions.couchdbserver.networks.int.ip}
couchdb couchdb/bindaddress seen true
couchdb couchdb/adminpass password ${COUCHDB_PASSWORD}
couchdb couchdb/adminpass seen true
couchdb couchdb/adminpass_again password ${COUCHDB_PASSWORD}
couchdb couchdb/adminpass_again seen true" | debconf-set-selections

DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes couchdb


systemctl stop couchdb

mkdir -p ${functions.couchdbserver.datadir}
rsync -a -v --ignore-existing "/var/lib/couchdb" "${functions.couchdbserver.datadir}"

cat <<EOT > /opt/couchdb/etc/default.d/20-databasedir.ini
#
# this file is automatically created by the:
# couchdbserver.sh function spawn machine setup script
#
[couchdb]
database_dir = ${functions.couchdbserver.datadir}
EOT

chown -R couchdb:couchdb ${functions.couchdbserver.datadir}
chown couchdb:couchdb /opt/couchdb/etc/default.d/20-databasedir.ini

# systemctl reload couchdb
systemctl restart couchdb

