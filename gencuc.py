import sqlite3
import datetime
import time
import sys
import os

dbpath="/nfs/OGN/SWdata/"
cucpath="/var/www/cuc/"
print "Gen live CUC files V1.0 from  "+dbpath+"SWIface.db"
start_time = time.time()
local_time = datetime.datetime.now()
fl_date_time = local_time.strftime("%Y%m%d")
CUC_DATA = cucpath + "LIVE" + fl_date_time+'.cuc'
print "CUC data file is: ", CUC_DATA
datafile = open (CUC_DATA, 'w')
cuchdr   = open (cucpath + "LIVEhdr.txt", 'r')
cuctail  = open (cucpath + "LIVEtail.txt", 'r')
buf=cuchdr.read()
datafile.write(buf)
conn=sqlite3.connect(dbpath+'SWiface.db')
cursD=conn.cursor()
cursG=conn.cursor()
pn=0
cursD.execute('select distinct idflarm from OGNDATA')
for row in cursD.fetchall():
    print row[0] 
    idflarm=row[0]
    idf=idflarm[3:9]
	
    print idf 
    cursG.execute("select registration, cn, type from GLIDERS where idglider = ?", [idf])
    gli=cursG.fetchone()
    if gli and gli != None:
                regi=gli[0]
                cn=gli[1]
		if cn == "":
			cn="NN"
                type=gli[2]
    else:
                regi='NO-NAME'
                cn='NN'
                type='NOTYPE'
    print "D==>: ", regi, cn, type
#   write the Pilot detail
#   "Tpilot","",*0,"FLRDDE1FC","Ventus","EC-TTT","TT","",0,"",0,"",1,"",""
    pn +=1 
    buf='"Pilot' +str(pn)+ '","",*0,"' +idflarm+ '","' +type+ '","' +regi+ '","' +cn+ '","",0,"",0,"",1,"",""\n' 
    datafile.write(buf)
    
# write the daye header

# [Starts]
#
# [Day_02/03/2016]
# D02032016-010400000

datafile.write("[Starts]\n")
datafile.write(" \n")
buf="[Day_"+local_time.strftime("%d/%m/%Y")+"]\n"
datafile.write(buf)
buf="D" + local_time.strftime("%d%m%Y") + "-010400000\n"
datafile.write(buf)

# close files and exit

buf=cuctail.read()
datafile.write(buf)
datafile.close()
cuchdr.close()
cuctail.close()
conn.commit()
conn.close()
if pn == 0:
	print "No pilots found ... CUC invalid"
	exit(-1)
else:
	print "Pilots found ... ", pn
	exit(0)
