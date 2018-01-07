#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import pathlib2

import re
import pprint as PPrint
from pprint import pprint

import logging
LOG = logging.getLogger("SpL."+__name__)

#LOG.addHandler(logging.NullHandler())
#LOG.setLevel(logging.DEBUG)
#LOG = logging

#LOG.warn("test")

class SimpleBashYamlTemplateEngine(object):
    """a simple template engine that does basically what
    string templates from standart lib does, 
    except that is takes dotted strings and looks
    them up in 'config' as nested dict
    
    config={'host':{'ip':10.0.0.1}}
    template_engine("my ip is ${host.ip}", config)
    "my ip is 10.0.0.1"
    
    keys/token that begin with ! are special commands
    
    keys that are not found are left as is.
    
    
    
    """
    
    def __init__(self, config, cwd=''):
        """Initialize a Template parser with a given config dict
        
        Keyword arguments
        config -- the config file to parse, nested dict
        cwd -- the directory to look in. used mainly for the commands,
               for example inclusion of other scripts..
        """
        
        """        
        dev-notes about the regex used:
        
        "\$\{\!?[\w.\-]+(\([\w/., ]*\))?\}"
                            -------    argmuments can be this separated by ,
                         --         --  ... in brackets
                        -              - optional subgroup
                       - identifier must be one char or more 
                 ------ identifier my constit of chars or .-
             -- optional !
         -- initial letter
         
        use this for testing:
        >>> re.sub("\$\{\!?[a-zA-Z_0-9.\-]+(\(.*\))?\}", "!", "test ${test()} ${!blaasdfasdf(sdf)}")
        """
        
        LOG.debug("setup template engine")
        self.cwd = pathlib2.Path(cwd)
        self.regex = re.compile("\$\{\!?[\w.\-]+(\([\w/., ]*\))?\}")

        self.lookup = self.create_lookup(config)
        self.cmds = self.define_commands()

        LOG.debug("setup template engine - done")
        
    def __call__(self, text, cwd=""):
        if cwd.exists():
            self.cwd = pathlib2.Path(cwd)
        return self.parse(text)

    def parse(self, text):
        return self.regex.sub(self.replace_token, text)


    def define_commands(self):
        """defines special commands in the form
        ${!include(args)}
        the brackets and args are optional!
        """
        
        def cmd_include(args):
            path = self.cwd.joinpath(args[0])
            if not path.is_file():
                LOG.critical("ABORT, can't include file <%s>", args[0])
                sys.exit(1)
            
            with path.open() as f:
                script = f.read()
                
            script = "\n".join(["", "## /----- INCLUDE <%s> \n" % path,
                     script,
                    "\n## \----- END INCLUDE" + "-"*55])

            return script
        
        
        cmds = {}
        cmds['include'] = cmd_include
        
        return cmds
        
        

    def create_lookup(self, config):
        """Uses a recursive function to scan the yaml
        config (now actually just a dict) and convert it
        into a "flat" dictonary with:
        - entries separated with SEP ('.' default)
        - lists enumerated
        
        Keyword args:
        config: dict with config
        
        Example:
        >>> d={'a1':'b1', 'a2': {'b2':'c1','b3':'c2'}, 'a3': ['b4','b5]}
        >>> create_lookup(d)
        {
          'a1': b1,
          'a2.b2': c1,
          'a2.b3': c2,
          'a3.0': b4,
          'a3.1': b5
        }
        """
        
        SEP = "."
        
        def create_lookup_recursive(config, pfx=""):
            if isinstance(config, dict):
                for k, v in config.items():
                    if len(pfx)<=0:
                        npfx=k
                    else:
                        npfx=pfx + SEP + k
                    create_lookup_recursive(v, pfx=npfx)
            elif isinstance(config, list):
                #lookup[pfx] = '[' + ", ".join(config) + ']'
                for i,k in enumerate(config):
                    npfx=pfx + SEP + str(i)
                    create_lookup_recursive(k, pfx=npfx)
            else:
                # print pfx+" : "+str(config)
                lookup[pfx] = config
        
        lookup = {}
        create_lookup_recursive(config)
        
        LOG.debug("CONFIG LOOKUP TABLE:")
        LOG.debug("\n"+PPrint.pformat(lookup, indent=2))

        return lookup


    def replace_token(self, sre_match):
        """helperfunction for the regex, 
        replaces the token by the actual text.
        - token is in config: replace by value from config
        - token is special command (starts with ${!xxx}): get teh commands return value
        - else return the token
        """
        lookup = self.lookup
        
        ostr = sre_match.group()
        key = ostr[2:-1]
        #print key

        if key in lookup.keys():
            return str(lookup[key])
        elif key[0] == "!": # special command?
            if "(" in key:
                cmd, args = key[1:-1].split("(", 1) # only slpit once, at the first (
                args = [_.strip() for _ in args.split(',')]
            else:
                cmd = key[1:]
                args = []
            #print "command: %s %s" % (cmd, args)
            
            if cmd in self.cmds.keys():
                return self.cmds[cmd](args)
            else:
                LOG.warn("TemplEngine didn't find nor replace command <%s>", cmd)
                return ostr
            
        else:
            return ostr
        
