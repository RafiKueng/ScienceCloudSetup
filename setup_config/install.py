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

__appname__ = "SpaghettiLens Cloud Installer"
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


reload(logging)
LOG = logging.getLogger(__appname__)


#def main(args):
    #config = yaml.safe_load(open("config.yml"))

    #install_funcs = args.functions
    
    #pprint(install_funcs)
    
class Tmpl_CMDs(object):
    
    def __init__(self):
        pass
    
    def __call__(self, cmd, args=[]):
        return getattr(self,cmd)(args)
        
    def include(self,args):
        return "INCLUDING FILE"
            
        
def template_engine(txt, config):
    """
    a simple template engine that does basically what
    string templates from standart lib does, 
    except that is takes dotted strings and looks
    them up in 'config' as nested dict
    
    config={'host':{'ip':10.0.0.1}}
    template_engine("my ip is ${host.ip}", config)
    "my ip is 10.0.0.1"
    
    keys that are not found are left as is.
    """
        
    
    # we assume that our templates have the format
    # ${a.b.c}
    
    regex = re.compile("\$\{[a-zA-Z_0-9.\-]+\}")
    
    lookup = {}
    CMDs = Tmpl_CMDs()
    
    def create_lookup(config, pfx=""):
        
        if isinstance(config, dict):
            for k, v in config.items():
                if len(pfx)<=0:
                    npfx=k
                else:
                    npfx=pfx+'.'+k
                create_lookup(v, pfx=npfx)
        elif isinstance(config, list):
            #lookup[pfx] = '[' + ", ".join(config) + ']'
            for i,k in enumerate(config):
                npfx=pfx+'.'+str(i)
                create_lookup(k, pfx=npfx)
        else:
            # print pfx+" : "+str(config)
            lookup[pfx] = config
    
    create_lookup(config)
    LOG.info("CONFIG LOOKUP TABLE:")
    LOG.info(PPrint.pformat(lookup, indent=2))
    
    def replace(sre_match):
        ostr = sre_match.group()
        key = ostr[2:-1]
        #print lstr, ";", s

        if key in lookup.keys():
            return str(lookup[key])
        elif key[0] == "!": # special command?
            if "(" in key:
                cmd, args = key[1:-1].split("(")
            else:
                cmd = key[1:]
                args = []
            return CMDs(cmd,args)
            
        else:
            return ostr
    
    return regex.sub(replace, txt)
    







    
    

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
    # during development, I set default to False so I don't have to keep
    # calling this with -v
    parser.add_argument('functions', action='store', nargs='+',
        help='the functions to install')

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
        


args = get_arguments()
setup_logger(args)


test_loader = unittest.TestLoader()
config = yaml.safe_load(open("config.yml"))

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
        LOG.warning("Function <%s> not defined in config.yaml" % fn)
        continue
    
    host = config['functions'][fn]['host']
    
    # check if host setup scripts are around
    scripts = map(pathlib2.Path, [
        os.path.join('server_spawn_openstack_setup', "%s.sh" %host),
        os.path.join('server_spawn_machine_setup', "%s.sh" %host),
        os.path.join('function_spawn_openstack_setup', "%s.sh" %fn),
        os.path.join('function_spawn_machine_setup', "%s.sh" %fn),
    ])

    for scr_path in scripts:
        if not scr_path.is_file():
            LOG.critical("ABORT! Function <%s>, Host <%s>: can't find: %s", fn, host, scr_path)
            sys.exit(1)

    test_suite = test_loader.discover('function_tests', pattern='%s.py' % fn)
    if not test_suite.countTestCases() > 0:
        LOG.warning("Function <%s> doesn't have any test cases defined" % fn)
        #continue
    
    try:
        module = importlib.import_module('%s.%s' % ('function_spawn_modules', fn))
    except ImportError:
        LOG.warning("Function <%s> doesn't have any install python code" % fn)
        #continue

    if not host in D['hosts_order']:
        D['hosts_order'].append(host)
        D['hosts'][host] = {
            'name': host,
            'openstack': hscripts[0],
            'machine': hscripts[1]
        }
    
    if not fn in D['funcs_order']:
        D['funcs_order'].append(fn)
        D['funcs'][fn] = {
            'name': fn,
            'host': host,
            'openstack': hscripts[2],
            'machine': hscripts[3],
            'module': module,
            'test': test_suite
        }



if len(D['funcs_order']) <= 0:
    LOG.critical("no functions to install, exiting")
    sys.exit(1)


LOG.info("Installing all host machine systems")

for hostname in D['hosts_order']:
    
    host = D['hosts'][hostname]
    #install_machine(host)
    #def install_machine(host):
    if True:
        hostname = host['name']
        openstackscript = host['openstack']
        machinescript   = host['machine']

        LOG.info("installing host <%s>", name)
        
        with openstackscript.open() as f:
            script = f.read()
         
        scripttxt = template_engine(script, config)
        
        scriptFile = NamedTemporaryFile(delete=True)
        with open(scriptFile.name, 'w') as f:
            # f.write("#!/bin/bash\n")
            f.write(scripttxt)

        os.chmod(scriptFile.name, 0777)
        scriptFile.file.close()

        print "------------------------------"
        print " running the script file:"
        print "------------------------------"
        print(script)
        print "------------------------------"
        print "output of script:"
        print "------------------------------"
        a = subprocess.check_call(scriptFile.name)
        print "------------------------------"





for fnc_d in fncs_to_install:
    
    #install_machine(fnc_d)
    #def install_machine(fnc_d):
    if True:
        pass
    

    #install(fnc_d)
    #def install(fnc_d):
    if True: 
        name = fnc_d['name']
        sc_script = fnc_d['openstackinstall_script']
        ma_script = fnc_d['machineinstall_script']
        module = fnc_d['module']
        suite = fnc_d['test']

        LOG.info("installing %s", name)
        
    
        with sc_script.open() as f:
            script = f.read()
         
        scripttxt = template_engine(script, config)
        
        scriptFile = NamedTemporaryFile(delete=True)
        with open(scriptFile.name, 'w') as f:
            f.write("#!/bin/bash\n")
            f.write(scripttxt)

        os.chmod(scriptFile.name, 0777)
        scriptFile.file.close()

        print "------------------------------"
        print " running the script file:"
        print "------------------------------"
        print(script)
        print "------------------------------"
        print "output of script:"
        print "------------------------------"
        a = subprocess.check_call(scriptFile.name)
        print "------------------------------"
        
    
    
LOG.info("Testing installation")

for fnc_d in fncs_to_install:

    name = fnc_d['name']
    ma_script = fnc_d['machineinstall_script']
    sc_script = fnc_d['openstackinstall_script']
    module = fnc_d['module']
    suite = fnc_d['test']

LOG.info("Installing functions: %s", fncs_to_install)



