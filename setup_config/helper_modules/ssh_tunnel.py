#!/usr/bin/env python
# -*- coding: utf-8 -*-


import subprocess
import logging

LOG = logging.getLogger("SpL."+__name__)


class SshTunnel(object):
    
    def __init__(self,
                 localport=10022,
                 targethost='localhost',
                 targetport=22,
                 proxyhost='root@localhost',
                 sockfile='/tmp/ssh_tunnel.sock',
                 **kwargs):
        """sets up an ssh tunnel, ala
    
        subprocess.call("ssh -f -N -M -S /tmp/SpLInst_sshtun.sock -L 10022:172.23.24.117:22 rafik@taurus.physik.uzh.ch", shell=True)
        """
        d = {
            'sock' : sockfile,
            'lport': str(localport),
            'thost': targethost,
            'tport': str(targetport),
            'proxy': proxyhost
        }
                
        self.cmd_start = ' '.join([
            "ssh",
            "-f -N -M",
            "-S {sock}",
            "-L {lport}:{thost}:{tport}",
            "{proxy}"
        ]).format(**d)
        
        self.cmd_end = " ".join([
            "ssh",
            "-S {sock}",
            "-O exit",
            "{proxy}"
        ]).format(**d)

    def __enter__(self):
        LOG.debug("building tunnel with cmd: %s", self.cmd_start)
        subprocess.call(self.cmd_start, shell=True)
        
    def __exit__(self, type, value, traceback):
        LOG.debug("tearing down tunnel with cmd: %s", self.cmd_end)
        subprocess.call(self.cmd_end, shell=True)


