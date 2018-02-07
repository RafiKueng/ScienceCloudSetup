#!/bin/bash

#
# Staticserver setup script
#

### settings ##################################################################

IP="10.0.6.1"
NR="01"

###############################################################################


### script ####################################################################
# run as sudo

# install webserver / load balancer
apt install nginx -y

# test webserver, might fail if running on shared machine
curl localhost

# remove default page
rm /etc/nginx/sites-enabled/default

cat <<EOT > /etc/nginx/sites-available/staticserver-${NR}.conf
server {
    listen ${IP}:80;
    
    root /var/www/labs.spacewarps.org-static;

    # special entry for testing purposes only
    location /static/_staticserver_test.tmp {
        return 200 'staticserver running';
        add_header Content-Type text/plain;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOT

ln -s /etc/nginx/sites-available/staticserver-${NR}.conf /etc/nginx/sites-enabled/staticserver-${NR}.conf


#
# Collect the static content and serve it under the folder
mkdir -p /var/www/labs.spacewarps.org-static
cat <<EOT > /var/www/labs.spacewarps.org-static/index.txt
A static file
EOT


# restart to reload config
systemctl restart nginx
