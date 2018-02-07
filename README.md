# How to setup SpaghettiLens on the ScienceCloud

[ which is an OpenStack instance ]

`source pyenv_uni/bin/activate`
`./openrc_v2.sh`

the magic happend in `cd setup_config`

then run `install.py [functions]`
where `functions` is a list of functions to setup, with according machines.

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


