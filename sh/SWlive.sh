#!/bin/sh
cd /nfs/OGN/SWdata
date >>proc.log
#python /nfs/OGN/src/SWsrc/SWiface.py >>proc.log &
python /home/pi/src/SWsrc/SWiface.py >>proc.log &
