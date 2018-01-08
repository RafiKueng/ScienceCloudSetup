#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
SYNOPSIS
    python SCRIPT.py [-h,--help] [-v,--verbose]
DESCRIPTION
    Concisely describe the purpose this script serves.
ARGUMENTS
    -h, --help		show this help message and exit
    -v, --verbose		verbose output
AUTHOR
    Doug McGeehan <djmvfb@mst.edu>
LICENSE
    Specify this script's / package's license.
"""

__appname__ = "SpaghettiLensCloudInstaller"
__author__  = "RafaelKueng <rafael.kueng@uzh.ch>"
__version__ = "0.1"
__license__ = "License"


import sys
import os
import pprint as PPrint
from pprint import pprint
import logging
import argparse
from datetime import datetime
import traceback

import pathlib2
import yaml
import unittest
import string
import collections
import re
import importlib
from tempfile import NamedTemporaryFile
import subprocess
import fabric
import fabric.api as fab

from helper_modules import template_engine, ssh_tunnel

reload(logging)
#LOG = logging.getLogger(__appname__)
#LOG = logging.getLogger(__name__)
LOG = logging.getLogger("SpL")

reload(template_engine)


#def main(args):
    #config = yaml.safe_load(open("config.yml"))

    #install_funcs = args.functions
    
    #pprint(install_funcs)


def print_script_output(outp, scriptname):
    
    LOG.info("\n".join([
        "output of script file <%s>:" % scriptname,
        "   /---vvv" + "-"*74 ,
        "\n".join(["   | "+_ for _ in outp.split("\n")]),
        "   \\---^^^" + "-"*74
    ]))
    


def run_script_locally(scriptFile):
    """locally runs a script file
    
    scriptFile -- pathlib2.Path to scriptfile
    """

    try:
        outp = subprocess.check_output(scriptFile.name, shell=True)
    except subprocess.CalledProcessError:
        LOG.critical("Script returned error! <%s>", scriptFile.name)
        sys.exit(1)

    return outp


def run_script_locally(scriptFile):
    """locally runs a script file
    
    scriptFile -- pathlib2.Path to scriptfile
    """

    tunset = config['conntection_settings']
    chost = tunset['controller']
    net =   tunset['network']
    tunset['targethost'] = get_assigned_machine_ip(chost, net)
    
    with ssh_tunnel.SshTunnel(**tunset) as tun:
            #localport=10022,
            #targethost="172.23.24.117", targetport=22,
            #proxyhost="rafik@taurus.physik.uzh.ch") as tun:
        
        fab.env.host_string = "debian@10.0.1.1"
        fab.env.gateway = "debian@localhost:10022"

        fab.put(scriptFile.name, scriptFile.name, mode="0755")
        
        # fab.run("hostname")
        outp = fab.sudo(scriptFile.name)
        fab.run("rm %s" % scriptFile.name )
        
    return outp




def open_and_parse_script_file(scriptpath):
    """Opens a script file, parses it,
    and returns a (closed) temporary file
    with the result. (use scriptFile.name
    to get the path.)
    
    Keyword arguments:
    scriptpath -- path to the script (pathlib2.Path)
    """
    try:
        with scriptpath.open() as f:
            script = f.read()
    except:
        LOG.critical("Cannot open script file (is it a pathlib2.Path??")
        sys.exit(1)
        
    #scripttxt = template_engine(script, config)
    scripttxt = TemplEngine(script, scriptpath.parent.absolute())
    
    scriptFile = NamedTemporaryFile(delete=True)
    LOG.debug("using script temp file: %s", scriptFile.name)
    with open(scriptFile.name, 'w') as f:
        # f.write("#!/bin/bash\n")
        f.write(scripttxt)

    os.chmod(scriptFile.name, 0777)
    scriptFile.file.close()

    LOG.debug("\n".join([
        "running the script file <%s>:" % scriptpath,
        "   /---vvv" + "-"*74 ,
        "\n".join(["   | "+_ for _ in scripttxt.split("\n")]),
        "   \\---^^^" + "-"*74
    ]))
    
    return scriptFile



def get_assigned_machine_ip(hostname="", network="uzh-only"):
    """Checks the openstack instance list and returns
    the ip of the <hostname> in the <network>
    """
    
    try:
        out = subprocess.check_output('openstack server list -f csv | grep %s' % hostname, shell=True)
    except subprocess.CalledProcessError:
        LOG.critical("Could not get the ip of <%s> in the net <%s>, aborting (is the openstack psw set / rc file sourced?)", hostname, network)
        sys.exit(1)
    
    nets = out.split(',')[3].strip('"')
    net = [_.strip() for _ in nets.split(';') if _.strip().startswith(network)][0]
    ip = net.split('=')[1]
    
    
    return ip


def get_flavours():
    try:
        out = subprocess.check_output('openstack flavor list -f yaml', shell=True)
    except subprocess.CalledProcessError:
        LOG.critical("Could not connect to openstack, aborting (is the openstack psw set / rc file sourced?)", hostname, network)
        sys.exit(1)

    flist = yaml.safe_load(out)
    fdict = {}
    for fl in flist:
        fdict[fl['Name']] = fl
    return fdict
    

def setup_logger(args):
    LOG.setLevel(logging.DEBUG)
    # create file handler which logs even debug messages
    # todo: place them in a log directory, or add the time to the log's
    # filename, or append to pre-existing log
    fh = logging.FileHandler(__appname__ + ".log")
    fh.setLevel(logging.DEBUG)
    # create console handler with a higher log level
    ch = logging.StreamHandler()

    if args.verbose:
        ch.setLevel(logging.DEBUG)
    else:
        ch.setLevel(logging.INFO)

    # create formatter and add it to the handlers
    fh.setFormatter(logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    ))
    ch.setFormatter(logging.Formatter(
        '%(levelname)s: %(message)s'
    ))
    # add the handlers to the LOG
    LOG.addHandler(fh)
    LOG.addHandler(ch)

    
def get_arguments():
    parser = argparse.ArgumentParser(
        description="Description printed to command-line if -h is called."
    )
    
    fntxt = "avaiable options: " + ", ".join(config['functions'].keys())
    parser.add_argument('functions', action='store', nargs='+',
        help='the functions to install. '+fntxt)

    # during development, I set default to False so I don't have to keep
    # calling this with -v
    parser.add_argument('-v', '--verbose', action='store_true',
        default=True, help='verbose output')

    return parser.parse_args()


if __name__ == '__main__':
    pass
    #try:
        #start_time = datetime.now()

        #args = get_arguments()
        #setup_LOG(args)
        #LOG.debug(start_time)

        #main(args)

        #finish_time = datetime.now()
        #LOG.debug(finish_time)
        #LOG.debug('Execution time: {time}'.format(
            #time=(finish_time - start_time)
        #))
        #LOG.debug("#"*20 + " END EXECUTION " + "#"*20)

        #sys.exit(0)

    #except KeyboardInterrupt as e: # Ctrl-C
        #raise e

    #except SystemExit as e: # sys.exit()
        #raise e

    #except Exception as e:
        #LOG.exception("Something happened and I don't know what to do D:")
        #sys.exit(1)
        

config = yaml.safe_load(open("config.yml"))

args = get_arguments()
setup_logger(args)

TemplEngine = template_engine.SimpleBashYamlTemplateEngine(config)

FLAVORS = get_flavours()

test_loader = unittest.TestLoader()

fncs_to_check = []
fncs_to_install = []

# first expand all functiongroups
for fng in args.functions:
    if fng in config['functiongroups'].keys():
        for fn in config['functiongroups'][fng]:
            fncs_to_check.append(fn)
    else:
        fncs_to_check.append(fng)


D = {
    'hosts': {},
    'hosts_order' : [],
    'funcs': {},
    'funcs_order' : []
}

# second check if functions are actually awailable
for fn in fncs_to_check:
    if not fn in config['functions'].keys():
        LOG.warning("Function <%s> not defined in config.yaml", fn)
        continue
    
    try:
        host = config['functions'][fn]['host']
        LOG.info("Function <%s> defines a host <%s>", fn, host)
        has_host = True
    except:
        LOG.info("Function <%s> didn't define a host", fn)
        host = ""
        has_host = False
    
    # check if host setup scripts are around
    scripts = map(pathlib2.Path, [
        os.path.join('server_spawn_openstack_setup', "%s.sh" %host),
        os.path.join('server_spawn_machine_setup', "%s.sh" %host),
        os.path.join('function_spawn_openstack_setup', "%s.sh" %fn),
        os.path.join('function_spawn_machine_setup', "%s.sh" %fn),
    ])

    for i, scr_path in enumerate(scripts):
        if not scr_path.is_file():
            LOG.info("Function <%s>, Host <%s>: can't find: %s", fn, host, scr_path)
            scripts[i] = None
        else:
            LOG.info("Function <%s>, Host <%s>: found script: %s", fn, host, scr_path)


    test_suite = test_loader.discover('function_tests', pattern='%s.py' % fn)
    if not test_suite.countTestCases() > 0:
        LOG.warning("Function <%s> doesn't have any test cases defined" % fn)
        test_suite = None
        #continue
    else:
        LOG.info("Function <%s> test suite loaded" % fn)
        
    
    try:
        module = importlib.import_module('%s.%s' % ('function_spawn_modules', fn))
        LOG.info("Function <%s> python code found" % fn)
    except ImportError:
        LOG.info("Function <%s> doesn't have any install python code" % fn)
        module = None
        #continue

    if has_host and not host in D['hosts_order']:
        D['hosts_order'].append(host)
        D['hosts'][host] = {
            'name': host,
            'openstack': scripts[0],
            'machine': scripts[1]
        }
    
    if not fn in D['funcs_order']:
        D['funcs_order'].append(fn)
        D['funcs'][fn] = {
            'name': fn,
            'host': host,
            'openstack': scripts[2],
            'machine': scripts[3],
            'module': module,
            'test': test_suite
        }



if len(D['funcs_order']) <= 0:
    LOG.critical("no functions to install, exiting")
    sys.exit(1)


LOG.info("-"*80)
LOG.info("installing host machines")
LOG.info("-"*80)

for hostname in D['hosts_order']:
    
    host = D['hosts'][hostname]
    
    #setup_machine_on_openstack(host)
    #def setup_machine_on_openstack(host):
    if True:

        hostname = host['name']
        openstackscript = host['openstack']
        #machinescript   = host['machine']
        
        if openstackscript is None:
            LOG.info("no openstackscript for host <%s>", hostname)

        else:
            LOG.info("setting up host <%s> on openstack", hostname)

            scriptFile = open_and_parse_script_file(openstackscript)
            outp = run_script_locally(scriptFile)
            print_script_output(outp, openstackscript)
            
            


    # install_machine_(host)
    #def install_machine(host):
    if True:

        hostname = host['name']
        # openstackscript = host['openstack']
        machinescript   = host['machine']

        if machinescript is None:
            LOG.info("no machinescript for host <%s>", hostname)

        else:
            LOG.info("setting up host <%s> on the machine", hostname)
            
            scriptFile = open_and_parse_script_file(machinescript)
            outp = run_script_remotly(scriptFile)
            print_script_output(outp, machinescript)
           


LOG.info("-"*80)
LOG.info("installing functions")
LOG.info("-"*80)

for fnc in D['funcs_order']:
    LOG.info("setting up function <%s>", fnc)

    fnc_d = D['funcs'][fnc]
    hostname = fnc_d['host']
    
    module = fnc_d['module']
    openstackscript = fnc_d['openstack']
    machinescript = fnc_d['machine']
    testsuite = fnc_d['test']

    if module is None:
        LOG.info("No module for function <%s>", fnc)
    else:
        LOG.info("running module for function <%s>", fnc)


    if openstackscript is None:
        LOG.info("No openstackscript for function <%s>", fnc)
    else:
        LOG.info("running openstackscript for function <%s>", fnc)

        scriptFile = open_and_parse_script_file(openstackscript)
        outp = run_script_locally(scriptFile)
        print_script_output(outp, openstackscript)



    if machinescript is None:
        LOG.info("No machinescript for function <%s>", fnc)
    else:
        LOG.info("running machinescript for function <%s>", fnc)

    if testsuite is None:
        LOG.info("No testsuite for function <%s>", fnc)
    else:
        LOG.info("running testsuite for function <%s>", fnc)



#for fnc_d in fncs_to_install:
    
    ##install_machine(fnc_d)
    ##def install_machine(fnc_d):
    #if True:
        #pass
    

    ##install(fnc_d)
    ##def install(fnc_d):
    #if True: 
        #name = fnc_d['name']
        #sc_script = fnc_d['openstackinstall_script']
        #ma_script = fnc_d['machineinstall_script']
        #module = fnc_d['module']
        #suite = fnc_d['test']

        #LOG.info("installing %s", name)
        
    
        #with sc_script.open() as f:
            #script = f.read()
         
        #scripttxt = template_engine(script, config)
        
        #scriptFile = NamedTemporaryFile(delete=True)
        #with open(scriptFile.name, 'w') as f:
            #f.write("#!/bin/bash\n")
            #f.write(scripttxt)

        #os.chmod(scriptFile.name, 0777)
        #scriptFile.file.close()

        #print "------------------------------"
        #print " running the script file:"
        #print "------------------------------"
        #print(script)
        #print "------------------------------"
        #print "output of script:"
        #print "------------------------------"
        #a = subprocess.check_call(scriptFile.name)
        #print "------------------------------"
        
    
    
#LOG.info("Testing installation")

#for fnc_d in fncs_to_install:

    #name = fnc_d['name']
    #ma_script = fnc_d['machineinstall_script']
    #sc_script = fnc_d['openstackinstall_script']
    #module = fnc_d['module']
    #suite = fnc_d['test']

#LOG.info("Installing functions: %s", fncs_to_install)



