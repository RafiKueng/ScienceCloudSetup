#!/bin/bash

# FUNCTION splapp SETUP SCRIPT
#
# reminder: this runs as sudo


apt install -y libevent-2.0-5
apt install -y python-greenlet python-eventlet python-gevent
apt install -y gunicorn 

apt install -y python-pip virtualenv

mkdir -p ${functions.splapp.appdir}

#TODO: get real app
cat <<EOT > "${functions.splapp.appdir}/test.py"
def app(environ, start_response):
    """Simplest possible application object"""
    data = 'Hello, World! from gunicorn\n'
    status = '200 OK'
    response_headers = [
        ('Content-type','text/plain'),
        ('Content-Length', str(len(data)))
    ]
    start_response(status, response_headers)
    return iter([data])

EOT


cat <<EOT > /etc/systemd/system/gunicorn.service
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
PIDFile=/run/gunicorn/pid
User=debian  
Group=debian  
RuntimeDirectory=gunicorn
WorkingDirectory=${functions.splapp.appdir}
ExecStart=/usr/bin/gunicorn \
    --pid /run/gunicorn/pid   \
    --workers 3 \
    --bind ${functions.splapp.networks.int.ip}:${functions.splapp.port} \
    test:app
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOT

systemctl start gunicorn
systemctl enable gunicorn



cd /srv/spl
git clone https://github.com/RafiKueng/SpaghettiLens.git spaghetti
cd spaghetti/
git checkout master

virtualenv ../venvs/spl
source ../venvs/spl/bin/activate
cp deploy/files/pip_requirements_server.txt ../requirements.txt
nano ../requirements.txt
pip install -r ../requirements.txt 

cd _app/
cp ../../deploy/files/django_machine_settings.py ./machine_settings.py
rm django_machine_settings.py
nano machine_settings.py

mkdir -p /run/gunicorn
chmod 777 /run/gunicorn
/srv/venvs/spl/bin/gunicorn --pid /run/gunicorn/pid --workers 3 --bind 10.0.2.1:8000 _app.wsgi

