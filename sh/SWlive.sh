#!/bin/sh
cd /nfs/OGN/SWdata
date >>SWproc.log

python ~/src/SWsrc/SWcalsunrisesunset.py >>SWproc.log 
python ~/src/SWsrc/SWiface.py   	 >>SWproc.log &
