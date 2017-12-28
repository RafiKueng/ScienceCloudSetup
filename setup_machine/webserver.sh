#!/bin/bash

#
# Webserver setup script
#


### settings ##################################################################

IP="10.0.5.1"
NR="01"

###############################################################################


### script ####################################################################

# install webserver / load balancer
sudo apt install nginx -y

# test webserver
curl localhost

# remove default page
sudo rm /etc/nginx/sites-enabled/default

cat <<EOT > /etc/nginx/sites-available/webserver-${NR}.conf
server {
    listen ${IP}:80;
    # listen 172.23.20.112:8080; # for debug purposes only

    # special entry for testing purposes only
    location /_webserver_test.tmp {
        return 200 'webserver running';
        add_header Content-Type text/plain;
    }

    root /var/www/labs.spacewarps.org;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOT

sudo ln -s /etc/nginx/sites-available/webserver-${NR}.conf /etc/nginx/sites-enabled/webserver-${NR}.conf


#
# Checkout the webserver content
mkdir -p /var/www/labs.spacewarps.org
cd /var/www/labs.spacewarps.org
cat <<EOT > index.html
<html><body>test</body></html>
EOT


# restart to reload config
sudo systemctl restart nginx
