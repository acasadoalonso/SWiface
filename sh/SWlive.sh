#!/bin/sh
cd /nfs/OGN/SWdata
date >>proc.log
#python /nfs/OGN/src/SWsrc/SWiface.py >>proc.log &
python ~/src/SWsrc/SWiface.py >>proc.log &
