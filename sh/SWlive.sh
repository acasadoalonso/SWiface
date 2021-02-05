#!/bin/sh
cd /nfs/OGN/SWdata
date >>SWproc.log
echo $(hostname)" running SWlive:"		>>SWproc.log
python3 ~/src/SWSsrc/SWcalsunrisesunset.py 	>>SWproc.log 
python3 ~/src/SWSsrc/SWiface.py   	 	>>SWproc.log &
