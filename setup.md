
# General overview of the setup

## Actual virtual machines used with CPU vram count

```
controller          1 / 1 server    -> 0.5 /  1
webserver           2 / 2 server    -> 1   /  2
server_all          4 / 4 server    -> 2   /  4
  - application server
  - static file server
  - broker
  - database

3 x
worker node         2 / 8 hpc       -> 6   / 24

------------------------------------------------
TOTAL                                  8.5 / 31

```


# Network / IP CONFIGURATION and machine / "task" list

Here there are basic tasks listed.. A Virtual machine can host multiple tasks (to not use too much CPUyrs)

```
Internal network runs on:   10.0.0.0/16
university only network on: 10.1.0.0/16
Internet network:           10.2.0.0/16
```

```
# q.r.0X.t Controller / Admin Area

10.0.0.1
10.1.0.1: "controller"
    there is only one instance

10.1.0.254: gateway
    gateway to hell uzh

10.2.0.254: gateway
    gateway to hell internet


10.0.1.1
10.2.1.1: "LoadBalancer"
    Use HAproxy for this
    no we use nginx here as well for the moment
    there might be more, but I only plan one for the moment.. This is basically a load balancer, so it shouldn't need to handle too much..


10.0.2.X: "CouchDBServer" database server
    there will probably be more than one, but let another girl/guy worry about how to shard CouchDB.. the loadbalancer should probably be on .1 later..
 

10.0.3.X: "MariaDBServer" database server
    At some point we might need one, but
    DONT USE IT FOR THE MOMENT


10.0.5.X: "WebServer"
    use nginx
    This serves basic pages, introduction, homepage, tutorials, ...
    serves files from
    /www/labs


10.0.6.X: "StaticServer"
    This serves static files from applications
    /www/static


10.0.9.X: "RabbitMQBroker"
  most certanly one broker will be sufficent forever.. 



# q.r.1X.t SpL AREA

10.0.10.X: "SpL-proxy" Initital ProxyServer for SpaghettiLens
    


10.0.11.X: "SpL-appserver" application server for spaghettilens
    plan for multiple


10.0.12.X: "SpL-mediaproxy"
    saves and serves the rendered media
    Actually only mounts an NFS share, or maybe a SWIFT container if available
    
    
10.0.13.X: "SpL-mediaserver"
    backend storage of media files, attach large volume here and share if using NFS
    not needed if SWIFT works
    

10.0.19.X: "SpL-worker" worker nodes
    there will be multiple amounts of worker


# q.r.2X.t SomeOtherApp AREA

10.0.20.X: "SomeOtherApp-proxy" application server for SomeOtherApp
    ...


# q.r.2X.t SomeOtherApp AREA

10.0.254.X: temporary assigned by DHCP, openstack
```



# A description of the Tasks

## Controller:
nginx serving admin and status pages

- celery flower
- rabbitmq status page
- django admin page



## Webserver:

nginx with php, setup load balancing
serve local files (tutorials, ect...)

application -> application server
static files -> static file server



## Application server:

serve application with gunicorn




## Static file server:

serve static files with nginx


## Broker:
rabbitmq


## Database:
couchdb


## Worker Node:
celeryd
http://docs.celeryproject.org/en/latest/userguide/daemonizing.html#usage-systemd







# Basic setup of openstack

## install CLI interface
due to bugs in python-pyperclip and python-cmd2 we use patched versions of those libs.
see here:
https://bugs.launchpad.net/ubuntu/+source/python-openstackclient/+bug/1722553

```
mkdir -p ~/projects/ScienceCloudSetup/
cd ~/projects/ScienceCloudSetup/
virtualenv pyenv
source pyenv/bin/activate

pip install --upgrade git+https://github.com/coreycb/pyperclip.git
pip install --upgrade git+https://github.com/coreycb/cmd2.git

pip install python-openstackclient

openstack
```


## download the rc v2 file from the website
```
wget https://cloud.s3it.uzh.ch/project/access_and_security/api_access/openrcv2/ openrc.v2.sh
```

## enable / test CLI
```
cd ~/projects/ScienceCloudSetup/
source pyenv/bin/activate
source openrc.v2.sh
openstack
```


# Initial Setup

## setup networks
create net_internal, net_uzh and net_internet networks with according subnets
internal has no gateway, others have gateway at `.0.254`
all have dhcp range `.254.1` -- `.254.99` (dhcp is needed to be able to assign fixed ports!!!)

```
net_internal    10.0.0.0/16
net_uzh         10.1.0.0/16
net_internet    10.2.0.0/16
```

## add routers to net_internal and net_internet


## setup network ports
`./setup_openstack/create_networkports.sh`


# setup instances

See the config files in the subfolders






