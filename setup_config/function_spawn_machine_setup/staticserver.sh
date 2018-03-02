#!/bin/bash

# FUNCTION staticserver SETUP SCRIPT
#
# reminder: this runs as sudo



apt install -y nginx

mkdir -p /srv/_test
cat <<EOT > /srv/_test/test2.html
hello world from a file from staticserver
EOT


cat <<EOT > /etc/nginx/sites-available/spl-static
server {
    listen ${functions.staticserver.port};
    server_name ${functions.staticserver.networks.int.ip};

    location /_test/test1.html {
        return 200 'static yupppa!';
        add_header Content-Type text/plain;
    }

    location /_test/test2.html {
        root /srv/;
    }
    

    location /static/ {
        root /srv/spl/static/
    }

    location / {
        root /srv/spl/static/
    }
}

EOT

rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-enabled/spl-static
ln -s ../sites-available/spl-static /etc/nginx/sites-enabled/spl-static

systemctl restart nginx

# collect static files

echo "please make sure to copy the files to $/srv/spl/static manually"
read -p "confirm with keypress", DUMMY

