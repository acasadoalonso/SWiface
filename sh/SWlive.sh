#!/bin/sh
cd /nfs/OGN/SWdata
date >>proc.log

python ~/src/SWsrc/SWcalsunrisesunset.py >>proc.log 
python ~/src/SWsrc/SWiface.py   	 >>proc.log &
