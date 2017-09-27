#!/usr/bin/python
#
# Python code to show access to OGN Beacons
#
# Version for gathering all the records for Spain 

from libfap import *
from ctypes import *
from datetime import datetime
import socket
import time
import string
import ephem
import pytz
import sys
import os
import os.path
import atexit
import signal
import kglid                                # import the list on known gliders
import socket
from   parserfuncs import *                 # the ogn/ham parser functions 
from   geopy.distance import vincenty       # use the Vincenty algorithm^M
from   geopy.geocoders import GeoNames      # use the Nominatim as the geolocator^M
from   time import sleep

#########################################################################
def shutdown(sock, datafile, tmaxa, tmaxt, tmid, tmstd):	# shutdown routine, close files and report on activity
                                        # shutdown before exit
    libfap.fap_cleanup()                # close lifap in order to avoid memory leaks
    sock.shutdown(0)                    # shutdown the connection
    sock.close()                        # close the connection file
    datafile.close()                    # close the data file 
    print 'Records read:',cin, ' Ids found: ',cout    # report number of records read and IDs discovered
    k=list(fid.keys())                  # list the IDs for debugging purposes
    k.sort()                            # sort the list
    for key in k:                       # report data
        gid='Noreg '                    # for unknown gliders
        if spanishsta(key) or frenchsta(key):
            if key in kglid.kglid:
                gid=kglid.kglid[key]    # report the station name
		if len(gid) > 20:
			gid=gid[0:20]
            else:
                gid="NOSTA"             # marked as no sta
        else:
            if key != None and key[3:9] in kglid.kglid: # if it is a known glider ???                                       
            	gid=kglid.kglid[key[3:9]]   # report the registration
	if key in fsmax:
	    	maxd=fsmax[key]
	else:
		if key in  fmaxd:
	    		maxd=fmaxd[key] 
		else:
	    		maxd=-1.0
	if key != fsta[key]:
        	if fmaxs[key] > 0:
            		print key, '=>', fsta[key], gid, fid[key], "Max alt:", fmaxa[key], "Max speed:", fmaxs[key], "Max. distance:", maxd 
									# report FLARM ID, station used, registration and record counter
        	else:
            		print key, '=>', fsta[key], gid, fid[key], "Max alt:", fmaxa[key], "Max. distance:", maxd

	if key == fsta[key] and key != None and key != "NONE  " and key in fslod:# in case of an receiver station , update the database with the coordinates
	    lati=fslla[key] 		# latitude
	    long=fsllo[key] 		# longitude
	    alti=fslal[key] 		# altitude
	    if (MySQL):
            	selcmd="SELECT * FROM  RECEIVERS WHERE  idrec =  '"+key+"'"
            	curs.execute(selcmd)
	    else:
            	selcmd="select idrec from RECEIVERS where idrec=?"	# SQL command to execute: SELECT
            	curs.execute(selcmd, (key,))
	    if curs.fetchone() == None:
		if (MySQL):
            		inscmd="insert into RECEIVERS values ('%s', '%s', %f,  %f,  %f)" % (key, gid, lati, long, alti)
                        try:
            			curs.execute(inscmd)
                        except MySQLdb.Error, e:
                                try:
                                        print ">>>MySQL Error [%d]: %s" % (e.args[0], e.args[1])
                                except IndexError:
                                        print ">>>MySQL Error: %s" % str(e)
                                print         ">>>MySQL error:", inscmd
		else:
            		inscmd="insert into RECEIVERS values (?, ?, ?, ?, ?)"
            		curs.execute(inscmd, (key, gid, lati, long, alti))
	    else:
		if (MySQL):
			if len(gid) > 30:
				descri = gid [0:30]
			else:
				descri=gid
            		updcmd="update RECEIVERS SET idrec='%s', descri='%s', lati=%f, longi=%f, alti=%f where idrec='%s' " % (key, descri, lati, long, alti, key)	# SQL command to execute: UPDATE
                        try:
            			curs.execute(updcmd)
                        except MySQLdb.Error, e:
                                try:
                                        print ">>>MySQL Error [%d]: %s" % (e.args[0], e.args[1])
                                except IndexError:
                                        print ">>>MySQL Error: %s" % str(e)
                                print         ">>>MySQL error:", updcmd
		else:
            		updcmd="update RECEIVERS SET idrec=?, descri=?, lati=?, longi=?, alti=? where idrec=?"	# SQL command to execute: UPDATE
            		curs.execute(updcmd, (key, gid, lati, long, alti, key))

	    print "Added STATION: ==> ", key, gid

#	end of if (for stations)
#   end of for 

                                        # report now the maximun altitude for the day
    if tmid[3:9] in kglid.kglid:        # if it is a known glider ???
        gid=kglid.kglid[tmid[3:9]]      # report the registration
    else:
        gid=tmid                        # use the ID instead   
    for key in fsmax:                   # report data
        print "Station: ", key, fsmax[key], "Kms. and" , fscnt[key], "fixes..."   
    print "Maximun altitude for the day:", tmaxa, ' meters MSL at:', tmaxt, 'by:', gid, 'Station:', tmsta, "Max. distance:", tmaxd, "by:", tmstd
    conn.commit()			# commit the DB updates
    conn.close()			# close the database
    local_time = datetime.now() 	# report date and time now
    location.date = ephem.Date(datetime.utcnow())
    print "Local Time (server) now is:", local_time, " and UTC time at location ", config.location_name, "is:", location.date, "UTC."
    try:
        os.remove(config.APP+".alive")		# delete the mark of alive
    except:
        print "No SW.live"
    return				# job done

#########################################################################

#########################################################################

def signal_term_handler(signal, frame):
    print 'got SIGTERM ... shutdown orderly'
    libfap.fap_cleanup()                        # close libfap
    shutdown(sock, datafile, tmaxa, tmaxt,tmid, tmstd) # shutdown orderly
    sys.exit(0)

#########################################################################
# ......................................................................# 
signal.signal(signal.SIGTERM, signal_term_handler)
# ......................................................................# 
def blackhole(lati, long):

	latn=42.72667
	lats=42.57833
	lonw=-0.1025
	lone=+0.18333
	if (lati < lats or lati > latn or long < lonw or long > lone):
		return (False)
	else:
		return (True)
########################################################################
def chkfilati(latitude,  flatil, flatiu):
	if (flatil == 0.0):
		return (False)
	if (flatil > 0):			# northern hemisphere
        	if (latitude < flatil or latitude > flatiu ):
			return (True)           
	else:                               	# southern hemisfere
                if (latitude > flatil or latitude < flatiu ):
			return (True)           
	return(False)
########################################################################

#----------------------ogn_SilentWingsInterface.py start-----------------------
pgmversion='V1.10' 
print "Start OGN Silent Wings Interface "+pgmversion
print "======================================"

print "Program Version:", time.ctime(os.path.getmtime(__file__))
date=datetime.utcnow()         		# get the date
dte=date.strftime("%y%m%d")             # today's date
hostname=socket.gethostname()
print "Date: ", date, " UTC at:", hostname, "Process ID:", os.getpid()

import config

if os.path.exists(config.PIDfile):	# protection against running the same daemon at the same time
	print "SWiface already running !!!"
	raise RuntimeError("SWiface already running !!!")
	exit(-1)			# exit with an error code
#
# --------------------------------------#
with open(config.PIDfile,"w") as f:	# protect against to running the daemon twice
	f.write (str(os.getpid()))
	f.close()
atexit.register(lambda: os.remove(config.PIDfile)) 	# remove the lock file at exit

# --------------------------------------#
location_latitude   	= config.location_latitude	# get the configuration parameters
location_longitude  	= config.location_longitude
DBpath			= config.DBpath 
DBhost   		= config.DBhost
DBuser   		= config.DBuser
DBpasswd 		= config.DBpasswd
DBname   		= config.DBname
MySQL 			= config.MySQL
SPIDER   		= config.SPIDER
SPOT     		= config.SPOT  
LT24     		= config.LT24  
OGNT     		= config.OGNT  
# --------------------------------------#

if SPIDER:				# check if we want the SPIDER to track
	from spifuncs import *
	spiusername =config.SPIuser  
	spipassword =config.SPIpassword  
	spisysid    =config.SPISYSid

if SPOT:				# check if we want the SPOT to track
	from spotfuncs import *

if LT24:				# check if we want the livetrack24 devices to track
	from lt24funcs import *
	lt24username =config.LT24username  
	lt24password =config.LT24password  
	LT24qwe=" "
	LT24_appSecret= " "
	LT24_appKey= " "
	LT24path=DBpath+"LT24/" 
	LT24login=False
	LT24firsttime=True


if OGNT:				# check if we want to add the OGN trackers to be pair with the Flarm units
	from ogntfuncs import *


# --------------------------------------#

fid=  {'NONE  ' : 0}                    # FLARM ID list
fsta= {'NONE  ' : 'NONE  '}             # STATION ID list
fmaxa={'NONE  ' : 0}                    # maximun altitude
fmaxd={'NONE  ' : 0}                    # maximun distance
fmaxs={'NONE  ' : 0}                    # maximun speed
cin   = 0                               # input record counter
cout  = 0                               # output file counter
i     = 0                               # loop counter
nerr  = 0
tmaxa = 0                               # maximun altitude for the day
tmaxt = 0                               # time at max altitude
tmaxd = 0                               # maximun distance
tmid  = 'NONE     '                     # glider ID obtaining max altitude
tmsta = '         '                     # station capturing max altitude
tmstd = '         '                     # station capturing max distance

fsllo={'NONE  ' : 0.0}      		# station location longitude
fslla={'NONE  ' : 0.0}      		# station location latitude
fslal={'NONE  ' : 0.0}      		# station location altitude
fslod={'NONE  ' : (0.0, 0.0)}           # station location - tuple
fsmax={'NONE  ' : 0.0}                  # maximun coverage
fsalt={'NONE  ' : 0}                    # maximun altitude
fscnt={'NONE  ' : 0}                    # tation counter

# --------------------------------------#
DBase=DBpath+'SWiface.db'		# Data base used
if (MySQL):
	import MySQLdb                  # the SQL data base routines^M
	conn=MySQLdb.connect(host=DBhost, user=DBuser, passwd=DBpasswd, db=DBname)
	print "MySQL Database:", DBname, " at Host:", DBhost
else:
	import sqlite3                  # the SQL data base routines^M
	conn=sqlite3.connect(DBase)	# connect with the database
	print "SQLITE3 Database: ",  DBase
# --------------------------------------#

curs=conn.cursor()                      # set the cursor
#
#-----------------------------------------------------------------
# Initialise API for computing sunrise and sunset
#-----------------------------------------------------------------
#
location = ephem.Observer()
location.pressure = 0
location.horizon = '-0:34'      # Adjustments for angle to horizon

location.lat, location.lon = location_latitude, location_longitude
date = datetime.now()
next_sunrise = location.next_rising(ephem.Sun(), date)
next_sunset = location.next_setting(ephem.Sun(), date)
print "Sunrise today is at: ", next_sunrise, " UTC "
print "Sunset  today is at: ", next_sunset,  " UTC "
print "Time now is: ", date, " Local time"

prtreq =  sys.argv[1:]
if prtreq and prtreq[0] == 'prt':
    prt = True
else:
    prt = False
 
if OGNT:			# if we need aggregation of FLARM and OGN trackers data
	ognttable={}		# init the instance of the table
	ogntbuildtable(conn, ognttable, prt) # build the table from the TRKDEVICES DB table 

# create socket & connect to server
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((config.APRS_SERVER_HOST, config.APRS_SERVER_PORT))
print "Socket sock connected"
 
# logon to OGN APRS network    
compfile=config.cucFileLocation + "/competitiongliders.lst"
if os.path.isfile(compfile):	# if we have a COMP file with the list of flarm ids, pass that to the APRS at login time
	fd=open(compfile, 'r')	# open and read the file
	j=fd.read()
	clist=json.loads(j)
	fd.close()		# close it
	filter="filter b/"	# prepare the fileter param of login
	for f in clist:		# explore the whole list
		filter += f	# add the flarm id
		filter += "/"	# separated by an slash

	if OGNT:
		for f in ognttable:
			filter += f	# add the flarm id
			filter += "/"	# separated by an slash

	if hostname == "CHILEOGN":
		filter += " p/SC/VITACURA/ROBLE/ELBOSQUE/TROCA/WBUX/COLORA/ \n"
	else:		
		filter += " p/LF/LE/ \n"# add all the station of france and Spain for control 
	login = 'user %s pass %s vers Silent-Wings-Interface %s %s'  % (config.APRS_USER, config.APRS_PASSCODE , pgmversion, filter)
else:
	login = 'user %s pass %s vers Silent-Wings-Interface %s %s'  % (config.APRS_USER, config.APRS_PASSCODE , pgmversion, config.APRS_FILTER_DETAILS)
print "APRS login:", login	# print the login for control
sock.send(login)    		# login into the APRS server
 
# Make the connection to the server
sock_file = sock.makefile()
 
# Initialise libfap.py for parsing returned lines
print "libfap_init"
libfap.fap_init()
start_time = time.time()	# get the start and local times
local_time = datetime.now()
fl_date_time = local_time.strftime("%y%m%d")
OGN_DATA = DBpath + "DATA" + fl_date_time+'.log'	# this is the LOG file
print "OGN data file is: ", OGN_DATA
datafile = open (OGN_DATA, 'a')
keepalive_count = 1		# number of keep alive messages
keepalive_time = time.time()	# every 3 minutees we send a keep alive message to the APRS server
alive(config.APP,first="yes")	# and we create a SWS.alive file for control that we are alive as well
#
#-----------------------------------------------------------------
# Initialise API for SPIDER & SPOT & LT24
#-----------------------------------------------------------------
#
now=datetime.utcnow()			# get the UTC time
min5=timedelta(seconds=300)		# 5 minutes ago
now=now-min5				# now less 5 minutes
td=now-datetime(1970,1,1)         	# number of seconds until beginning of the day 1-1-1970
ts=int(td.total_seconds())		# Unix time - seconds from the epoch
spispotcount=1				# loop counter
ttime=now.strftime("%Y-%m-%dT%H:%M:%SZ")# format required by SPIDER

if LT24:				# if we use LT24, we do the login now
	lt24login(LT24path, lt24username, lt24password)	# login into the LiveTrack24 server
	lt24ts=ts
	LT24firsttime=True

if SPIDER or SPOT or LT24:		# if we use SPIDER, SPOT or LT24 we print the control
	print spispotcount, "---> TTime:", ttime, "Unix time:", ts, "UTC:", datetime.utcnow().isoformat()

date = datetime.now()

#
#-----------------------------------------------------------------
# Initialise API for computing sunrise and sunset
#-----------------------------------------------------------------
#
location = ephem.Observer()
location.pressure = 0
location.horizon = '-0:34'		# Adjustments for angle to horizon

try:

    while True:
        location.date = ephem.Date(datetime.utcnow())		# check the localtime for this location...
        date =                     datetime.utcnow()		# time of the server
        localdate =                datetime.now()		# time of the server
        if location.date > next_sunset or localdate.hour > 21:	# if it is past the sunset or 22:00h local time ??

            print "At Sunset now ... Time is (server):", date, "UTC. Location time:", location.date, "UTC ... Next sunset is: ", next_sunset,  " UTC"
            shutdown(sock, datafile, tmaxa, tmaxt,tmid, tmstd)
            print "At Sunset ... Exit"
            exit(0)

        # Loop for a long time with a count

        current_time = time.time()
        elapsed_time = current_time - keepalive_time
        if (current_time - keepalive_time) > 180:        # keepalives every 3 mins
            try:
                rtn = sock_file.write("# Python SWSiface App\n\n")
                # Make sure keepalive gets sent. If not flushed then buffered
                sock_file.flush()			# force to write the data
                datafile.flush()			# use this ocassion to flush as well the data file
		alive(config.APP)			# indicate that we are alive
                run_time = time.time() - start_time	# get the run time
                if prt:
                    print "Send keepalive no: ", keepalive_count, " After elapsed_time: ", int((current_time - keepalive_time)), " After runtime: ", int(run_time), " secs"
                keepalive_time = current_time
                keepalive_count +=  1

            except Exception, e:
 
               	print ('Something\'s wrong with socket write. Exception type is %s' % (`e`))
	       	print "Socket error:", keepalive_count, current_time
		if keepalive_count != -1:
			keepalive_count=-1
            		shutdown(sock, datafile, tmaxa, tmaxt,tmid, tmstd)
            	print "At socket error ... Exit"
            	exit(-1)
 
            try:						# lets see if we have data from the interface functionns: SPIDER, SPOT, LT24 or SKYLINES
			if SPIDER:				# if we have SPIDER according with the config

				ttime=spifindspiderpos(ttime, conn, spiusername, spipassword, spisysid)

			else: 
				ttime=now.strftime("%Y-%m-%dT%H:%M:%SZ")# format required by SPIDER

			if SPOT:				# if we have the SPOT according with the configuration

				ts   =spotfindpos(ts, conn)
			else:

				td=now-datetime(1970,1,1)      	# number of second until beginning of the day
				ts=int(td.total_seconds())	# Unix time - seconds from the epoch
			if LT24:				# if we have the LT24 according with the configuration
		
				lt24ts   =lt24findpos(lt24ts, conn, LT24firsttime) # find the position and add it to the DDBB
				LT24firsttime=False		# only once the addpos
			else:
				td=now-datetime(1970,1,1)      	# number of second until beginning of the day
				lt24ts=int(td.total_seconds())	# Unix time - seconds from the epoch

			if OGNT:				# if we need aggregation of FLARM and OGN trackers data
				ogntbuildtable(conn, ognttable, prt) # rebuild the table from the TRKDEVICES DB table 
			spispotcount += 1			# we report a counter of calls to the interfaces 
			if SPIDER or SPOT or LT24:
				print spispotcount, "---> Spider TTime:", ttime, "SPOT Unix time:", ts, "LT24 Unix time", lt24ts, "UTC Now:", datetime.utcnow().isoformat()


            except Exception, e:				# if we have an error during the aggregation functions 
                        print ('Something\'s wrong with interface functions Exception type is %s' % (`e`))
			if SPIDER or SPOT or LT24:
				print spispotcount, "ERROR:---> Spider TTime:", ttime, "SPOT Unix time:", ts, "LT24 Unix time", lt24ts, "UTC Now:", datetime.utcnow().isoformat()


# ------------------------------------------------------- main loop ------------------------------------- #    


        if prt:
            print "In main loop. Count= ", i
            i += 1
        try:
            # Read packet string from socket
            packet_str = sock_file.readline()
	    
            if len(packet_str) > 0 and packet_str[0] <> "#":
                datafile.write(packet_str)
                
        except socket.error:
            print "Socket error on readline"
            nerr +=1
            if nerr > 20:
                print "Socket error multiple  Failures.  Orderly closeout, keep alive count:", keepalive_count
                date = datetime.now()
                print "UTC now is: ", date
                break
            else:
		sleep(5)					# sleep for 5 seconds and give it another chance
            	continue
        # A zero length line should not be return if keepalives are being sent
        # A zero length line will only be returned after ~30m if keepalives are not sent
        if len(packet_str) == 0:
            nerr +=1
            if nerr > 20:
                print "Read returns zero length string. Failure.  Orderly closeout, keep alive count:", keepalive_count
                date = datetime.now()
                print "UTC now is: ", date
                break
            else:
		sleep(5)					# sleep for 5 seconds and give it another chance
                continue
	if prt:
		print "DATA:", packet_str			# print the data received
    	ix=packet_str.find('>')					# convert to uppercase the ID
    	cc= packet_str[0:ix]					# just the ID
    	cc=cc.upper()
    	packet_str=cc+packet_str[ix:]				# now with the ID in uppercase
	msg={}							# create the dict 
        if  len(packet_str) > 0 and packet_str[0] <> "#":	# only in case that is data coming

            	msg=parseraprs(packet_str, msg)			# parse the message into the dict
		if prt:
			print msg
                id        = msg['id']                         	# id
                type      = msg['type']				# aprs message type
                longitude = msg['longitude']			# and so on ...
                latitude  = msg['latitude']
                altitude  = msg['altitude']
                path      = msg['path']
                otime     = msg['otime']
                source    = msg['source']
                if path == 'qAS' or path == 'RELAY*' or path[0:3] == "OGN": # if std records
                        station=msg['station']
			if path[0:3] == "OGN":
				print "RELAY:", path, station
		else:
			station=id				# otherwise is the ID of the data received
                data=packet_str
	    	if not id in fid :                  		# if we did not see the FLARM ID
                	fid[id]=0                       	# init the counter
                	fsta[id]=station                     	# init the station receiver
                	fmaxa[id]=altitude              	# maximun altitude
                	fmaxs[id]=0                     	# maximun speed
                	fmaxd[id]=0.0	                	# maximun distance
                	cout += 1                       	# one more file to create
	    	else:
			fid[id] += 1				# increase the counter

            	if path == 'TCPIP*':				# handle the TCPIP
                	if not id in fslod :
                   		fslla[id]=latitude		# save the location of the station
                   		fsllo[id]=longitude		# save the location of the station
                   		fslal[id]=altitude		# save the location of the station
                   		fslod[id]=(latitude, longitude) # save the location of the station
                   		fsmax[id]=0.0                	# initial coverage distance is zero
                   		fsalt[id]=0                  	# initial coverage altitude is zero
                   		fscnt[id]=0                  	# initial counter of fixes
				status=msg['status']		# station status
                        	temp=msg['temp']		# station temperature
                        	version=msg['version']		# station SW version
                        	cpu=msg['cpu']			# station CPU load
                        	rf=msg['rf']			# station RF sensibility
		   		print "===>STA:", id, latitude, longitude, altitude, version, ":::", status
                	continue                        	# go for the next record

		if type == 8:					# if tracker status report
			print "OGN tracker Status report:", data
			continue
	    	if path == 'qAC':
			continue				# the case of the TCP IP as well
                if path == 'qAS' or path == 'RELAY*' or path[0:3] == "OGN": # if std records
                        station=msg['station']
			fsta[id]=station                	# init the station receiver
                else:
                        continue                        	# nothing else to do
                course    = msg['course']			# heading
                speed     = msg['speed']
                uniqueid  = msg['uniqueid']
                extpos    = msg['extpos']
                roclimb   = msg['roclimb']			# rate of climb
                rot       = msg['rot']
                sensitivity= msg['sensitivity']
                gps       = msg['gps']
                hora      = msg['time']				# fix time
                altim=altitude                          	# the altitude in meters
	    	# filter by latitude
	    	if config.FILTER_LATI1 > 0:			# if we are in the norther hemisfere
	    		if (chkfilati(latitude, config.FILTER_LATI1, config.FILTER_LATI2) and chkfilati(latitude, config.FILTER_LATI3, config.FILTER_LATI4)): 
				continue			# if is not within our latitude ignore the data
	    	if (blackhole(longitude, latitude)):
			print "BH:", id, longitude, latitude, date
			continue				# if is not within our latitude ignore the data
 
            	if altitude >= fmaxa[id]:			# check for maximun altitude
                	fmaxa[id] = altitude
                	if altitude > tmaxa and (not spanishsta(id) and not frenchsta(id)):
                        	tmaxa = altitude        	# maximum altitude for the day
                        	tmaxt = date            	# and time
                        	tmid  = id              	# who did it
                        	tmsta = station         	# station capturing the max altitude
            	if speed >= fmaxs[id]:				# check for maximun speed
               		fmaxs[id] = speed
            	if altim > 15000 or altim < 0:	
                	altim=0
            	alti='%05d' % altim                 		# convert it to an string
	    	dist=-1
            	if station in fslod:                		# if we have the station yet
                	distance=vincenty((latitude, longitude), fslod[station]).km    # distance to the station
                	dist=distance
                	if distance > 299.9:			# posible errors 
                    		print "distcheck: ", distance, data
                	elif distance > fsmax[station]: 	# if higher distance
                    		fsmax[station]=distance     	# save the new distance
                	if altim > fsalt[station]:  		# if higher altitude
                    		fsalt[station]=altim    	# save the new altitude
			if distance > tmaxd:			# if exceed maximun distance 
		    		tmaxd=distance			# maximun distance today
		    		tmstd=station			# station with the maximun distance
			if distance >fmaxd[id]:			# if distance is higher 
		    		fmaxd[id]=distance		# save the new distance
			fscnt[station] += 1			# increase the counter of fixes
		if source != "OGN":				# if it is not OGN, we get the distance to the home base
                	distance=vincenty((latitude, longitude), (config.location_latitude, config.location_longitude)).km    # distance to the base
                	dist=distance
            	if altim > tmaxa:				# if exceed the maximun altitude
                	tmaxa = altim               		# maximum altitude for the day
                	tmaxt = hora                		# and time
                	tmid  = id                  		# who did it
                	tmsta = station             		# station capturing the max altitude
            	if prt:
                	print 'Parsed data: POS: ', longitude, latitude, altitude,' Speed:',speed,' Course: ',course,' Path: ',path,' Type:', type
                	print roclimb, rot, sensitivity, gps, uniqueid, dist, extpos, source
	    	if rot== ' ':
			rot=0
	    	if sensitivity == ' ':
			sensitivity=0
		if OGNT and id[0:3] == 'OGN':			# if we have OGN tracker aggregation and is an OGN tracker
			if id in ognttable:			# if the device is on the list
				id=ognttable[id]		# substitude the OGN tracker ID for the related FLARMID
            # write the DB record

	    	if (MySQL):
                	addcmd="insert into OGNDATA values ('" +id+ "','" + dte+ "','" + hora+ "','" + station+ "'," + str(latitude)+ "," +\
				 str(longitude)+ "," + str(altim)+ "," + str(speed)+ "," + \
				 str(course)+ "," + str(roclimb)+ "," +str(rot) + "," +str(sensitivity) + \
                		 ",'" + gps+ "','" + uniqueid+ "'," + str(dist)+ ",'" + extpos+ "','"+source+"')"
                	try:
                        	curs.execute(addcmd)
                	except MySQLdb.Error, e:
                        	try:
                                	print ">>>MySQL Error [%d]: %s" % (e.args[0], e.args[1])
                        	except IndexError:
                                	print ">>>MySQL Error: %s" % str(e)
                        	print         ">>>MySQL error:", cin, addcmd
            	else:
                	addcmd="insert into OGNDATA values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
                	curs.execute(addcmd, (id, dte, hora, station, latitude, longitude, altim, speed, course, roclimb, rot,sensitivity, gps, uniqueid, dist, extpos, source))
		if prt:
			print addcmd
            	conn.commit()                       		# commit the DB updates
	    	cin +=1                             		# one more record read
        

except KeyboardInterrupt:
    print "Keyboard input received, ignore"
    pass

print 'Counters:', cin, cout                # report number of records read and files generated
shutdown(sock, datafile, tmaxa, tmaxt,tmid, tmstd)
location.date = ephem.Date(datetime.utcnow())
print "Exit now ...", location.date
if nerr > 0:
	print "Number of errors:", nerr
exit(1)



