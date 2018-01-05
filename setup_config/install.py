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

reload(logging)
logger = logging.getLogger(__appname__)


#def main(args):
    #config = yaml.safe_load(open("config.yml"))

    #install_funcs = args.functions
    
    #pprint(install_funcs)
    

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
    
    def create_lookup(config, pfx=""):
        
        if isinstance(config, dict):
            for k, v in config.items():
                if len(pfx)<=0:
                    npfx=k
                else:
                    npfx=pfx+'.'+k
                create_lookup(v, pfx=npfx)
        elif isinstance(config, list):
            lookup[pfx] = '[' + ", ".join(config) + ']'
            #for k in config:
                ## print pfx+'.'+k+"  : none"
                #lookup[pfx+'.'+k] = ""
        else:
            # print pfx+" : "+str(config)
            lookup[pfx] = config
    
    create_lookup(config)
    pprint(lookup)
    
    def replace(sre_match):
        ostr = sre_match.group()
        key = ostr[2:-1]
        #print lstr, ";", s

        if key in lookup.keys():
            return str(lookup[key])
        else:
            return ostr
    
    return regex.sub(replace, txt)
    
        
        
    
    

def setup_logger(args):
    logger.setLevel(logging.DEBUG)
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
    # add the handlers to the logger
    logger.addHandler(fh)
    logger.addHandler(ch)

    
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
        #setup_logger(args)
        #logger.debug(start_time)

        #main(args)

        #finish_time = datetime.now()
        #logger.debug(finish_time)
        #logger.debug('Execution time: {time}'.format(
            #time=(finish_time - start_time)
        #))
        #logger.debug("#"*20 + " END EXECUTION " + "#"*20)

        #sys.exit(0)

    #except KeyboardInterrupt as e: # Ctrl-C
        #raise e

    #except SystemExit as e: # sys.exit()
        #raise e

    #except Exception as e:
        #logger.exception("Something happened and I don't know what to do D:")
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

# second check if functions are actually awailable
for fn in fncs_to_check:
    if not fn in config['functions'].keys():
        logger.warning("Function <%s> not defined in config.yaml" % fn)
        continue
    
    installscript = pathlib2.Path("installscripts/%s.sh" % fn)
    if not installscript.is_file():
        logger.warning("Function <%s> doesn't have an installscript in subdir" % fn)
        continue
    
    test_suite = test_loader.discover('test_functions', pattern='%s.py' % fn)
    if not test_suite.countTestCases() > 0:
        logger.warning("Function <%s> doesn;t have any test cases defined" % fn)
        continue
        
    d = {'name':fn, 'script': installscript, 'test':test_suite}
    #d = (fn, installscript, test_suite)
    fncs_to_install.append(d)
    
if len(fncs_to_install) <= 0:
    logger.critical("no functions to install, exiting")
    sys.exit(1)



logger.info("Installing all systems")

for fnc_d in fncs_to_install:
    name = fnc_d['name']
    script = fnc_d['script']
    suite = fnc_d['test']
    
    with script.open() as f:
        txt=f.read()
    
    s = template_engine(txt, config)
    print s 
    
    
logger.info("Testing installation")

for fnc_d in fncs_to_install:
    name = fnc_d['name']
    script = fnc_d['script']
    suite = fnc_d['test']
    unittest.TextTestRunner(verbosity=2).run(suite)


logger.info("Installing functions: %s", fncs_to_install)



