#!/bin/sh
cd ~/src
rsync -rl /var/www .
cd ~/src/SWsrc
git pull origin master
rsync  ~/src/*.sh /nfs/OGN/src/SWsrc/sh 
cd /nfs/OGN/src
cp libfap.py kglid.py parserfuncs.py ~/src/SWsrc
cd
