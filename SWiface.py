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
import signal
import kglid                                # import the list on known gliders
import socket
from   parserfuncs import *                 # the ogn/ham parser functions 
from   geopy.distance import vincenty       # use the Vincenty algorithm^M
from   geopy.geocoders import GeoNames      # use the Nominatim as the geolocator^M
from   configparser import ConfigParser

configfile='/etc/local/SWSconfig.ini'	    # location of the configuration file

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
            		updcmd="update RECEIVERS SET idrec='%s', descri='%s', lati=%f, longi=%f, alti=%f where idrec='%s' " % (key, gid, lati, long, alti, key)	# SQL command to execute: UPDATE
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
        print "Station: ", key, fsmax[key], "Kms."    
    print "Maximun altitude for the day:", tmaxa, ' meters MSL at:', tmaxt, 'by:', gid, 'Station:', tmsta, "Max. distance:", tmaxd, "by:", tmstd
    conn.commit()			# commit the DB updates
    conn.close()			# close the database
    local_time = datetime.now() 	# report date and time now
    location.date = ephem.Date(datetime.utcnow())
    print "Local Time (server) now is:", local_time, " and UTC time at location is:", location.date, "UTC."
    try:
        os.remove("OGN.alive")		# delete the mark of alive
    except:
        print "No OGN.live"
    return				# job done

#########################################################################
 
#########################################################################
def alive(first='no'):

        if (first == 'yes'):
                alivefile = open ("SW.alive", 'w') # create a file just to mark that we are alive
        else:
                alivefile = open ("SW.alive", 'a') # append a file just to mark that we are alive
        local_time = datetime.now()
        alivetime = local_time.strftime("%y-%m-%d %H:%M:%S")
        alivefile.write(alivetime+"\n") # write the time as control
        alivefile.close()               # close the alive file
#########################################################################
#########################################################################

def signal_term_handler(signal, frame):
    print 'got SIGTERM ... shutdown orderly'
    libfap.fap_cleanup()                        # close libfap
    shutdown(sock, datafile, tmaxa, tmaxt,tmid, tmstd) # shutdown orderly
    sys.exit(0)

# ......................................................................# 
signal.signal(signal.SIGTERM, signal_term_handler)
# ......................................................................# 
#
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
########################################################################

#----------------------ogn_SilentWingsInterface.py start-----------------------
 
print "Start OGN Silent Wings Interface V1.4"
print "====================================="



#-------------------------------------
# OGN-Silent Wings interface --- Settings 
#-------------------------------------
#
#-------------------------------------
# Setting values
#-------------------------------------
#
hostname=socket.gethostname()
print "Hostname:", hostname
cfg=ConfigParser()								# get the configuration parameters
cfg.read(configfile)								# reading it for the configuration file
print "Config.ini sections:", cfg.sections()					# report the different sections

APRS_SERVER_HOST 	= cfg.get    ('APRS', 'APRS_SERVER_HOST').strip("'").strip('"')
APRS_SERVER_PORT 	= int(cfg.get('APRS', 'APRS_SERVER_PORT'))
APRS_USER        	= cfg.get    ('APRS', 'APRS_USER').strip("'").strip('"')
APRS_PASSCODE    	= int(cfg.get('APRS', 'APRS_PASSCODE'))			# See http://www.george-smart.co.uk/wiki/APRS_Callpass
APRS_FILTER_DETAILS 	= cfg.get    ('APRS', 'APRS_FILTER_DETAILS').strip("'").strip('"') 
APRS_FILTER_DETAILS	= APRS_FILTER_DETAILS + '\n '

location_latitude   	= cfg.get('location', 'location_latitude').strip("'").strip('"')
location_longitude  	= cfg.get('location', 'location_longitud').strip("'").strip('"')

FILTER_LATI1     	= float(cfg.get('filter', 'FILTER_LATI1'))
FILTER_LATI2     	= float(cfg.get('filter', 'FILTER_LATI2'))
FILTER_LATI3     	= float(cfg.get('filter', 'FILTER_LATI3'))
FILTER_LATI4     	= float(cfg.get('filter', 'FILTER_LATI4'))

DBpath			= cfg.get('server', 'DBpath').strip("'").strip('"')
MySQLtext		= cfg.get('server', 'MySQL').strip("'").strip('"')
DBhost   		= cfg.get('server', 'DBhost').strip("'").strip('"')
DBuser   		= cfg.get('server', 'DBuser').strip("'").strip('"')
DBpasswd 		= cfg.get('server', 'DBpasswd').strip("'").strip('"')
DBname   		= cfg.get('server', 'DBname').strip("'").strip('"')

if (MySQLtext == 'True'):
	MySQL = True
else:
	MySQL = False
# --------------------------------------#
assert len(APRS_USER) > 3 and len(str(APRS_PASSCODE)) > 0, 'Please set APRS_USER and APRS_PASSCODE in settings.py.'
										# report the configuration paramenters
print "Config server values:", 			MySQL, DBhost, DBuser, DBpasswd, DBname, DBpath 
print "Config APRS values:", 			APRS_SERVER_HOST, APRS_SERVER_PORT, APRS_USER, APRS_PASSCODE, APRS_FILTER_DETAILS
print "Config location and filter values:", 	location_latitude, location_longitude, "FILTER:", FILTER_LATI1, FILTER_LATI2,FILTER_LATI3,FILTER_LATI4
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

# --------------------------------------#
DBase=DBpath+'SWiface.db'		# Data base used
if (MySQL):
	import MySQLdb                  # the SQL data base routines^M
else:
	import sqlite3                  # the SQL data base routines^M
# --------------------------------------#
if (MySQL):
	conn=MySQLdb.connect(host=DBhost, user=DBuser, passwd=DBpasswd, db=DBname)
else:
	conn=sqlite3.connect(DBase)	# connect with the database

curs=conn.cursor()                      # set the cursor
date=datetime.utcnow()         		# get the date
dte=date.strftime("%y%m%d")             # today's date
#
#-----------------------------------------------------------------
# Initialise API for computing sunrise and sunset
#-----------------------------------------------------------------
#
location = ephem.Observer()
location.pressure = 0
location.horizon = '-0:34'      # Adjustments for angle to horizon

if (MySQL):
	print "MySQL: Database:", DBname, " at Host:", DBhost
else:
	print "Database: ",  DBase
print "Date: ", date, "at:", socket.gethostname()
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
 
# create socket & connect to server
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((APRS_SERVER_HOST, APRS_SERVER_PORT))
print "Socket sock connected"
 
# logon to OGN APRS network    

login = 'user %s pass %s vers Silent Wings-Interface 1.0 %s'  % (APRS_USER, APRS_PASSCODE , APRS_FILTER_DETAILS)
sock.send(login)    
 
# Make the connection to the server
sock_file = sock.makefile()
 
# Initialise libfap.py for parsing returned lines
print "libfap_init"
libfap.fap_init()
start_time = time.time()
local_time = datetime.now()
fl_date_time = local_time.strftime("%y%m%d")
OGN_DATA = DBpath + "DATA" + fl_date_time+'.log'
print "OGN data file is: ", OGN_DATA
datafile = open (OGN_DATA, 'a')
keepalive_count = 1
keepalive_time = time.time()
alive("yes")
#
#-----------------------------------------------------------------
# Initialise API for computing sunrise and sunset
#-----------------------------------------------------------------
#
location = ephem.Observer()
location.pressure = 0
location.horizon = '-0:34'	# Adjustments for angle to horizon

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

        #Loop for a long time with a count, illustrative only
        current_time = time.time()
        elapsed_time = current_time - keepalive_time
        if (current_time - keepalive_time) > 180:        # keepalives every 3 mins
            try:
                rtn = sock_file.write("#Python ognES App\n\n")
                # Make sure keepalive gets sent. If not flushed then buffered
                sock_file.flush()
                datafile.flush()
		alive()					# indicate that we are alive
                run_time = time.time() - start_time
                if prt:
                    print "Send keepalive no: ", keepalive_count, " After elapsed_time: ", int((current_time - keepalive_time)), " After runtime: ", int(run_time), " secs"
                keepalive_time = current_time
                keepalive_count = keepalive_count + 1
            except Exception, e:
                print ('something\'s wrong with socket write. Exception type is %s' % (`e`))
     
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
            continue
        # A zero length line should not be return if keepalives are being sent
        # A zero length line will only be returned after ~30m if keepalives are not sent
        if len(packet_str) == 0:
            nerr +=1
            if nerr > 25:
                print "Read returns zero length string. Failure.  Orderly closeout"
                date = datetime.now()
                print "UTC now is: ", date
                break
            else:
                continue
	if prt:
		print "DATA:", packet_str
    	ix=packet_str.find('>')
    	cc= packet_str[0:ix]
    	cc=cc.upper()
    	packet_str=cc+packet_str[ix:]
	msg={}
        if  len(packet_str) > 0 and packet_str[0] <> "#":

            	msg=parseraprs(packet_str, msg)
                id        = msg['id']                         # id
                longitude = msg['longitude']
                latitude  = msg['latitude']
                altitude  = msg['altitude']
                path      = msg['path']
                otime     = msg['otime']
                type      = msg['type']
                if path == 'qAS' or path == 'RELAY*':           # if std records
                        station=msg['station']
		else:
			station=id
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
				status=msg['status']
                        	temp=msg['temp']
                        	version=msg['version']
                        	cpu=msg['cpu']
                        	rf=msg['rf']
		   		print "===>STA:", id, latitude, longitude, altitude, version, temp, "C", cpu, "%", rf, ":::", status
                	continue                        	# go for the next record

	    	if path == 'qAC':
			continue				# the case of the TCP IP as well
                if path == 'qAS' or path == 'RELAY*':           # if std records
                        station=msg['station']
			fsta[id]=station                	# init the station receiver
                else:
                        continue                        	# nothing else to do
                course    = msg['course']
                speed     = msg['speed']
                uniqueid  = msg['uniqueid']
                extpos    = msg['extpos']
                roclimb   = msg['roclimb']
                rot       = msg['rot']
                sensitivity= msg['sensitivity']
                gps       = msg['gps']
                hora      = msg['time']
                altim=altitude                          	# the altitude in meters
	    # filter by latitude
	    	if FILTER_LATI1 > 0:				# if we are in the norther hemisfere
	    		if (chkfilati(latitude, FILTER_LATI1, FILTER_LATI2) and chkfilati(latitude, FILTER_LATI3, FILTER_LATI4)): 
				continue			# if is not within our latitude ignore the data
	    	if (blackhole(longitude, latitude)):
			print "BH:", id, longitude, latitude, date
			continue				# if is not within our latitude ignore the data
 
            	if altitude >= fmaxa[id]:
                	fmaxa[id] = altitude
                	if altitude > tmaxa and (not spanishsta(id) and not frenchsta(id)):
                        	tmaxa = altitude        	# maximum altitude for the day
                        	tmaxt = date            	# and time
                        	tmid  = id              	# who did it
                        	tmsta = station         	# station capturing the max altitude
            	if speed >= fmaxs[id]:
               		fmaxs[id] = speed
            	if altim > 15000 or altim < 0:
                	altim=0
            	alti='%05d' % altim                 		# convert it to an string
	    	dist=-1
            	if station in fslod:                		# if we have the station yet
                	distance=vincenty((latitude, longitude), fslod[station]).km    # distance to the station
                	dist=distance
                	if distance > 250.0:
                    		print "distcheck: ", distance, data
                	elif distance > fsmax[station]: 	# if higher distance
                    		fsmax[station]=distance     	# save the new distance
                	if altim > fsalt[station]:  		# if higher altitude
                    		fsalt[station]=altim    	# save the new altitude
			if distance > tmaxd:			# if exceed maximun distance 
		    		tmaxd=distance			# maximun distance today
		    		tmstd=station			# station with the maximun distance
			if distance >fmaxd[id]:
		    		fmaxd[id]=distance
            	if altim > tmaxa:				# if exceed the maximun altitude
                	tmaxa = altim               		# maximum altitude for the day
                	tmaxt = hora                		# and time
                	tmid  = id                  		# who did it
                	tmsta = station             		# station capturing the max altitude
            	if prt:
                	print 'Parsed data: POS: ', longitude, latitude, altitude,' Speed:',speed,' Course: ',course,' Path: ',path,' Type:', type
                	print roclimb, rot, sensitivity, gps, uniqueid, dist, extpos
	    	if rot== ' ':
			rot=0
	    	if sensitivity == ' ':
			sensitivity=0
            # write the DB record

	    	if (MySQL):
                	addcmd="insert into OGNDATA values ('" +id+ "','" + dte+ "','" + hora+ "','" + station+ "'," + str(latitude)+ "," +\
				 str(longitude)+ "," + str(altim)+ "," + str(speed)+ "," + \
				 str(course)+ "," + str(roclimb)+ "," +str(rot) + "," +str(sensitivity) + \
                		 ",'" + gps+ "','" + uniqueid+ "'," + str(dist)+ ",'" + extpos+ "')"
                	try:
                        	curs.execute(addcmd)
                	except MySQLdb.Error, e:
                        	try:
                                	print ">>>MySQL Error [%d]: %s" % (e.args[0], e.args[1])
                        	except IndexError:
                                	print ">>>MySQL Error: %s" % str(e)
                        	print         ">>>MySQL error:", cin, addcmd
            	else:
                	addcmd="insert into OGNDATA values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
                	curs.execute(addcmd, (id, dte, hora, station, latitude, longitude, altim, speed, course, roclimb, rot,sensitivity, gps, uniqueid, dist, extpos))

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



