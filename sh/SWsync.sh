#!/bin/sh
cd ~/src
rsync -rl /var/www .
cd ~/src/SWsrc/main
git pull origin master
rsync  ~/src/*.sh /nfs/OGN/src/SWsrc/sh 
cp /nfs/OGN/src/SWsrc/*.py ~/src/SWsrc
cd /nfs/OGN/src
cp libfap.py kglid.py *funcs.py ~/src/SWsrc
cd
