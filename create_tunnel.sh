#!/bin/bash

#
# creates an ssh tunnel through taurus to the controller node.
# first arg is ip of controller node
# this is NOT needed during deployment!
#

echo "ctrl+c to exit. (DONT FORGET THE IP OF CONTROLLER NODE AS \$1)"
echo "use: ssh debian@localhost -p 10023" 
ssh -Y -N -M -S /tmp/SpLInst_sshtun2.sock -L 10023:$1:22 rafik@taurus.physik.uzh.ch 

