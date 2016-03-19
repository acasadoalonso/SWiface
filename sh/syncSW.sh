#!/bin/sh
cd /home/pi/src
rsync -rl /nfs/OGN/src/SWsrc .
rsync -rl /var/www .
cd
