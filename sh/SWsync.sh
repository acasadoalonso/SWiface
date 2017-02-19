#!/bin/sh
cd ~/src
rsync -rl  ./SWsrc /nfs/OGN/src/
rsync -rl /var/www .
rsync  ~/src/*.sh /nfs/OGN/src/SWsrc/sh 
cd /nfs/OGN/src
cp libfap.py kglid.py parserfuncs.py ~/src/SWsrc
cd
