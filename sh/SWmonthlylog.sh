#!/bin/bash
cd /nfs/OGN/SWdata
mv proc.log log/proc$(date +%m%y).log
mv err.log    log/err$(date    +%m%y).log
cd archive
rm        db/SWiface.BKUP.db
cp OGN.db db/SWiface.BKUP.db
sqlite3 SWiface.db "vacuum;"
mv DATA$(date +%y)*.log Y$(date +%y) 
cd
