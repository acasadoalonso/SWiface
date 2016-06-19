#!/bin/sh
cd /home/pi/src
rsync -rl  ./SWsrc /nfs/OGN/src/
rsync -rl /var/www .
rsync  /home/pi/src /nfs/OGN/src/SWsrc/sh 
cd /nfs/OGN/src
cp libfap.py kglid.py parserfuncs.py /home/pi/src/SWsrc
cd
