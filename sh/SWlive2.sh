#!/bin/sh
cd /nfs/OGN/SWdata
echo "LIVE.sh:" 	>>proc.log
date 			>>proc.log
cd /var/www/html
python genconfig.py
cd /nfs/OGN/SWdata
echo "Generated config.py :" 	>>proc.log
date 			>>proc.log
python ~/src/SWsrc/SWiface.py >>proc.log &
