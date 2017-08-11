#!/bin/sh
cd /nfs/OGN/SWdata
echo "LIVE.sh:" 	>>SWproc.log
date 			>>SWproc.log
cd /var/www/html
python genconfig.py
cd /nfs/OGN/SWdata
echo "Generated config.py :" 			>>SWproc.log
date 						>>SWproc.log
python ~/src/SWsrc/SWcalsunrisesunset.py 	>>SWproc.log
python ~/src/SWsrc/SWiface.py 			>>SWproc.log &
