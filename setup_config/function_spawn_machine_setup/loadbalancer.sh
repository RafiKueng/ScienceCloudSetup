#!/bin/bash

# FUNCTION LOADBALANCER SETUP SCRIPT
#
# reminder: this runs as sudo



apt install -y nginx

mkdir -p /srv/_test
cat <<EOT > /srv/_test/test2.html
hello world from a file
EOT


cat <<EOT > /etc/nginx/sites-available/spl
server {
    listen ${functions.loadbalancer.port};
    server_name ${functions.loadbalancer.networks.ext.ip};

    location /_test/test1.html {
        return 200 'yupppa!';
        add_header Content-Type text/plain;
    }

    location /_test/test2.html {
        root /srv/;
    }
    
    # location = /favicon.ico { access_log off; log_not_found off; }
    
    location /static/ {
        include proxy_params;
        proxy_pass http://${functions.staticserver.networks.int.ip}:${functions.staticserver.port};
    }

    location / {
        include proxy_params;
        proxy_pass http://${functions.splapp.networks.int.ip}:${functions.splapp.port};
    }
}

EOT

rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-enabled/spl
ln -s ../sites-available/spl /etc/nginx/sites-enabled/spl


# collect static files

