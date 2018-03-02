#!/bin/bash

# FUNCTION splapp SETUP SCRIPT
#
# reminder: this runs as sudo


apt install -y libevent-2.0-5
apt install -y python-greenlet python-eventlet python-gevent
# apt install -y gunicorn 

apt install -y python-pip virtualenv

mkdir -p ${functions.splapp.appdir}
# 
# #TODO: get real app
# cat <<EOT > "${functions.splapp.appdir}/test.py"
# def app(environ, start_response):
#     """Simplest possible application object"""
#     data = 'Hello, World! from gunicorn\n'
#     status = '200 OK'
#     response_headers = [
#         ('Content-type','text/plain'),
#         ('Content-Length', str(len(data)))
#     ]
#     start_response(status, response_headers)
#     return iter([data])
# 
# EOT


PATH_base="/srv/spl"  # ${functions.splapp.appdir}
FOLDER_src="spaghetti-src"
PATH_full="${PATH_base}/${FOLDER_src}"
PATH_venv="${PATH_base}/venvs/spl-main"

if [ ! -d "$PATH_full" ]; then
    git clone https://github.com/RafiKueng/SpaghettiLens.git "${PATH_full}"
fi
cd "${PATH_full}"
git pull
git checkout master


mkdir -p "${PATH_venv}/.."
virtualenv "${PATH_venv}"
source "${PATH_venv}/bin/activate"
pip install -r "${PATH_full}/py_requirements/appserver.txt"

cat <<EOT > "${PATH_full}/apps/_app/machine_settings.py"
# -*- coding: utf-8 -*-
"""
This file gets modified and automatically uploaded by the deploy script.
Make any changes there and re deploy!!! Don't do any manual changes here..
(esp. the settings.py file)

@author: rafik
"""

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True
TEMPLATE_DEBUG = True

# Database
# https://docs.djangoproject.com/en/1.7/ref/settings/#databases
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME'  : 'db.sqlite3',

    }
}

COUCHDB_DATABASES = (
    ('djangoapp.spaghetti', 'http://10.0.2.1:5984/spaghetti'),
    ('djangoapp.lenses',    'http://10.0.2.1:5984/lenses'),
)

STATIC_ROOT = '/srv/spl/static'
MEDIA_ROOT = '/srv/spl/media'

UPLOAD_USER = 'rafik'
UPLOAD_HOST = '192.168.100.10'

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = ')ir@&^cmbu$e+btd&dske8h&u+u8dy9=mmho*tc171*0f!q@xn'

# Celery / Broker Configuration
BROKER_URL = 'amqp://rabbituser:CmPszRRKQZGC7KGU@10.0.2.1:5672/swlabs'
CELERY_RESULT_BACKEND = 'amqp://rabbituser:CmPszRRKQZGC7KGU@10.0.2.1:5672/swlabs/'

EOT



# collect the static files for staticserver
cd "${PATH_full}/apps"
python manage.py collectstatic

#python manage.py sync_prepare_couchdb
#python manage.py sync_finish_couchdb
#python manage.py sync_couchdb
python manage.py syncdb

# autostart the daemon

mkdir -p /run/gunicorn
chmod 777 /run/gunicorn
# /srv/venvs/spl/bin/gunicorn --pid /run/gunicorn/pid --workers 3 --bind 10.0.2.1:8000 _app.wsgi

# # backup
# ExecStart=/usr/bin/gunicorn \
#     --pid /run/gunicorn/pid   \
#     --workers 3 \
#     --bind ${functions.splapp.networks.int.ip}:${functions.splapp.port} \
#     test:app



cat <<EOT > /etc/systemd/system/gunicorn.service
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
PIDFile=/run/gunicorn/pid
User=debian  
Group=debian  
RuntimeDirectory=gunicorn
WorkingDirectory=${PATH_full}/apps
PermissionsStartOnly=true
ExecStartPre=/bin/mkdir -p /run/gunicorn
ExecStartPre=/bin/chown -R debian:debian /run/gunicorn
ExecStart=${PATH_venv}/bin/gunicorn --pid /run/gunicorn/pid --workers 3 --bind ${functions.splapp.networks.int.ip}:${functions.splapp.port} _app.wsgi
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOT

systemctl start gunicorn
systemctl enable gunicorn



