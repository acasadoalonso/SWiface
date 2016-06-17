#!/bin/sh
rm kglid.pyc
rm kglid.bkup
mv kglid.py kglid.bkup
wget repoogn.ddns.net:50080/DIRdata/kglid.py -O kglid.py --user=acasado --password=correo
ls -la
