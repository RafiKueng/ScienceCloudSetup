# How to setup SpaghettiLens on the ScienceCloud

[ which is an OpenStack instance ]

`source pyenv_uni/bin/activate`
`./openrc_v2.sh`

the magic happend in `cd setup_config`

then run `install.py [functions]`
where `functions` is a list of functions to setup, with according machines.
or it can be a "functiongroup", which is simply a shortcut name for a list of functions. Consult `config.yaml` at the bottom for definitions.

These `functions` are defined in the `config.yaml` file and have according install scripts in the according foders.

Please note: multiple `functions` can run on one (virtual) `server`. When isntalling a function, the server gets installed as well, if required.

There are always two parts involved, a user side script that sets up openstack and the machines, and a "server" side script that runs on the virtual machine..
`function_spawn_openstack_setup` vs `function_spawn_machine_setup` (`function_spawn_modules` are python scripts to run that replace/complement the bash scripts in `function_spawn_openstack_setup` if I figure out python access to openstack API).

The same for the setup of servers: `server_spawn_machine_setup` vs `server_spawn_openstack_setup`.

These files are quasi bash scripts, some invvented bash template language. Variables in these scripts get replaced by their values, if they exist in `config.yaml`.

for example:

```
#!/bin/bash
NETWORKNAME="${networks.internal.name}"
echo $NETWORKNAME
```
for details see `helper_modules/template_engine.py`.



--------
# TODO NEXT

- complete install.py: run function machine script remotely
- complete install.py: run function module script 
- complete install.py: run function testsuite script 
- setup the actual machines

--------


## Functions

### init
runs on: none

basic function that initializes the openstack environment...

sets up:
- internal network & subnetwork

still todo:
- other networks?
- routers? (maybe with outwards facing function)
- install ssk keypair
- security groups



### basiccontroller
runs on: saturn

this is the main instance that:
- functions as ssh gateway to the internal network to all other machines

still todo:
- offers monitoring functionality from net-uzh to net-int
- fires up and tears down worker nodes


### loadbalancer
runs on: mimas

function:
- gateway machine that redirects requests if required and answers static files.

still todo:





## Machines

### saturn
1 core low ram, machine only used for monitoring


### mimas
2cpu-2ram-server, gateway proxy machine


