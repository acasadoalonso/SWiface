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
import settings
import string
import datetime
import ephem
import pytz
import sys
import os
import kglid                                # import the list on known gliders
from   parserfuncs import *                 # the ogn/ham parser functions 
from   geopy.distance import vincenty       # use the Vincenty algorithm^M
from   geopy.geocoders import GeoNames      # use the Nominatim as the geolocator^M
import sqlite3                              # the SQL data base routines^M

#########################################################################
def shutdown(sock, datafile, tmaxa, tmaxt, tmid):	# shutdown routine, close files and report on activity
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

        if fmaxs[key] > 0:
            print key, '=>', fsta[key], gid, fid[key], "Max alt:", fmaxa[key], "Max speed:", fmaxs[key] # report FLARM ID, station used, registration and record counter
        else:
            print key, '=>', fsta[key], gid, fid[key], "Max alt:", fmaxa[key]

	if key == fsta[key] and key != None and key != "NONE  ":# in case of an receiver station , update the database with the coordinates
	    lati=fslla[key] 		# latitude
	    long=fsllo[key] 		# longitude
	    alti=fslal[key] 		# altitude
            selcmd="select idrec from RECEIVERS where idrec=?"	# SQL command to execute: SELECT
            curs.execute(selcmd, (key,))
	    if curs.fetchone() == None:
            	inscmd="insert into RECEIVERS values (?, ?, ?, ?, ?)"
            	curs.execute(inscmd, (key, gid, lati, long, alti))
	    else:
            	updcmd="update RECEIVERS SET idrec=?, desc=?, lati=?, longi=?, alti=? where idrec=?"	# SQL command to execute: UPDATE
            	curs.execute(updcmd, (key, gid, lati, long, alti, key))
	    print "Added STATION: ==> ", key, gid, fslla[key], fsllo[key], fslal[key] 
                                        # report now the maximun altitude for the day
    if tmid[3:9] in kglid.kglid:        # if it is a known glider ???
        gid=kglid.kglid[tmid[3:9]]      # report the registration
    else:
        gid=tmid                        # use the ID instead       
    print "Maximun altitude for the day:", tmaxa, ' meters MSL at:', tmaxt, 'by:', gid, 'Station:', tmsta
    conn.commit()			# commit the DB updates
    conn.close()			# close the database
    local_time = datetime.datetime.now() # report date and time now
    print "Time now:", local_time
    return				# job done

#########################################################################

fid=  {'NONE  ' : 0}                    # FLARM ID list
fsta= {'NONE  ' : 'NONE  '}             # STATION ID list
fmaxa={'NONE  ' : 0}                    # maximun altitude
fmaxs={'NONE  ' : 0}                    # maximun speed
cin   = 0                               # input record counter
cout  = 0                               # output file counter
i     = 0                               # loop counter
err   = 0
tmaxa = 0                               # maximun altitude for the day
tmaxt = 0                               # time at max altitude
tmid  = 'NONE     '                     # glider ID obtaining max altitude
tmsta = '         '                     # station capturing max altitude

fsllo={'NONE  ' : 0.0}      		# station location longitude
fslla={'NONE  ' : 0.0}      		# station location latitude
fslal={'NONE  ' : 0.0}      		# station location altitude
fslod={'NONE  ' : (0.0, 0.0)}           # station location - tuple
fsmax={'NONE  ' : 0.0}                  # maximun coverage
fsalt={'NONE  ' : 0}                    # maximun altitude

lastp_lati={"LECD" : +42.38695}         # the dummy competitor
lastp_long={"LECD" : +1.86843}          # the dummy competitor
lastp_alti={"LECD" : +1105.8144}        # the dummy competitor

DBase=settings.DBpath+'SWiface.db'	# Data base used
conn=sqlite3.connect(DBase)		# connect with the database
curs=conn.cursor()                      # set the cursor
date=datetime.datetime.now()            # get the date
dte=date.strftime("%y%m%d")             # today's date

#----------------------ogn_SilentWingsInterface.py start-----------------------
 
print "Start OGN Silent Wings Interface"
print "================================"

print "Database: ",  DBase
print "Date: ", date
prtreq =  sys.argv[1:]
if prtreq and prtreq[0] == 'prt':
    prt = True
else:
    prt = False
    
# create socket & connect to server
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((settings.APRS_SERVER_HOST, settings.APRS_SERVER_PORT))
print "Socket sock connected"
 
# logon to OGN APRS network    

login = 'user %s pass %s vers Silent Wings-Interface 1.0 %s'  % (settings.APRS_USER, settings.APRS_PASSCODE , settings.APRS_FILTER_DETAILS)
sock.send(login)    
 
# Make the connection to the server
sock_file = sock.makefile()
 
# Initialise libfap.py for parsing returned lines
print "libfap_init"
libfap.fap_init()
start_time = time.time()
local_time = datetime.datetime.now()
fl_date_time = local_time.strftime("%y%m%d")
OGN_DATA = settings.DBpath + "DATA" + fl_date_time+'.log'
print "OGN data file is: ", OGN_DATA
datafile = open (OGN_DATA, 'a')
keepalive_count = 1
keepalive_time = time.time()

#
#-----------------------------------------------------------------
# Initialise API for computing sunrise and sunset
#-----------------------------------------------------------------
#
location = ephem.Observer()
location.pressure = 0
location.horizon = '-0:34'	# Adjustments for angle to horizon

location.lat, location.lon = settings.FLOGGER_LATITUDE, settings.FLOGGER_LONGITUDE
date = datetime.datetime.now()
next_sunrise = location.next_rising(ephem.Sun(), date)
next_sunset = location.next_setting(ephem.Sun(), date)
print "Sunrise today is at: ", next_sunrise, " UTC "
print "Sunset  today is at: ", next_sunset,  " UTC "
print "Time now is: ", date

try:

    while True:
        #Loop for a long time with a count, illustrative only
        current_time = time.time()
        elapsed_time = current_time - keepalive_time
        if (current_time - keepalive_time) > 300:        # keepalives every 5 mins
            try:
                rtn = sock_file.write("#Python ognES App\n\n")
                # Make sure keepalive gets sent. If not flushed then buffered
                sock_file.flush()
                datafile.flush()
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
            err +=1
            if err > 9:
                print "Read returns zero length string. Failure.  Orderly closeout"
                date = datetime.datetime.now()
                print "UTC now is: ", date
                break
            else:
                continue

        # Parse packet using libfap.py into fields to process, eg:
        packet = libfap.fap_parseaprs(packet_str, len(packet_str), 0)
        if  len(packet_str) > 0 and packet_str[0] <> "#":
            callsign=packet[0].src_callsign     # get the call sign FLARM ID
            id=callsign                         # id
            longitude = get_longitude(packet)
            latitude  = get_latitude(packet)
            altitude  = get_altitude(packet)
            speed     = get_speed(packet)
            course    = get_course(packet)
            path      = get_path(packet)
            type      = get_type(packet)
            dst_callsign = get_dst_callsign(packet)
            destination  = get_destination(packet)
            header       = get_header(packet)
            if prt:
                print 'Packet returned is: ', packet_str
                print 'Callsign is: ', callsign, 'DST CallSign:', dst_callsign, 'Dest: ', destination, 'header: ', header
            if not id in fid :                  # if we did not see the FLARM ID
                fid[id]=0                       # init the counter
                fsta[id]=id                     # init the station receiver
                fmaxa[id]=altitude              # maximun altitude
                fmaxs[id]=speed                 # maximun speed
                cout += 1                       # one more file to create
            if path == 'TCPIP*':		# handle the TCPIP
                if not id in fslod :
                   fslla[id]=latitude		# save the location of the station
                   fsllo[id]=longitude		# save the location of the station
                   fslal[id]=altitude		# save the location of the station
                   fslod[id]=(latitude, longitude) # save the location of the station
                   fsmax[id]=0.0                # initial coverage zero
                   fsalt[id]=0                  # initial coverage zero
		   if prt :
		   	print "===>STA:", id, latitude, longitude, altitude
                continue                           # go for the next record


	    if path == 'qAC':
		continue			# the case of the TCP IP as well
            if path == 'qAS':                   # if std records
                station = packet_str[19:23]     # get the station identifier
                if station == 'LECI' or station == 'CREA':
                    station=packet_str[19:24]   # just a hack !!!
		if station == 'Madr':
                    station=packet_str[19:25]   # just a hack !!!
                fsta[id]=station                # init the station receiver
		    
            else:
		continue 			# nothing else to do
            fid[id] +=1                         # increase the number of records read
	    lastp_lati[id]=latitude		# update the last knoow position of the glider
	    lastp_long[id]=longitude		# update the last knoow position of the glider
	    lastp_alti[id]=altitude		# update the last knoow position of the glider
            if altitude >= fmaxa[id]:
                fmaxa[id] = altitude
                if altitude > tmaxa and (not spanishsta(id) and not frenchsta(id)):
                        tmaxa = altitude        # maximum altitude for the day
                        tmaxt = date            # and time
                        tmid  = id              # who did it
                        tmsta = station         # station capturing the max altitude
            if speed >= fmaxs[id]:
                fmaxs[id] = speed
	    data=packet_str
            p1=data.find(':/')+2                # scan for the body of the APRS message
            hora=data[p1:p1+6]                  # get the GPS time in UTC
            long=data[p1+7:p1+11]+data[p1+12:p1+14]+'0'+data[p1+14]         # get the longitude
            lati=data[p1+16:p1+21]+data[p1+22:p1+24]+'0'+data[p1+24]        # get the latitude
            p2=data.find('/A=')+3               # scan for the altitude on the body of the message
            altif=data[p2+1:p2+6]               # get the altitude in feet
            if  data[p2+7] == '!':              # get the unique id
            	uniqueid     = data[p2+13:p2+23] # get the unique id
            	extpos       = data[p2+7:p2+12] # get extended position indicator
	    else:
            	uniqueid     = data[p2+7:p2+17] # get the unique id
		extpos=' '
            p3=data.find('fpm')                 # scan for the rate of climb
            roclimb      = data[p3-3:p3]        # get the rate of climb
            p4=data.find('rot')                 # scan for the rate of climb
            rot      = data[p4-3:p4]            # get the rate of turn
            p5=data.find('dB')                  # scan for the sensitivity
            sensitivity = data[p5-4:p5]         # get the sensitivity
            p6=data.find('gps')                 # scan for gps info
            gps      = data[p6:p6+6]            # get the gps
            altim=altitude                      # the altitude in meters
            if altim > 15000 or altim < 0:
                altim=0
            alti='%05d' % altim                 # convert it to an string
	    dist=-1
            if station in fslod:                # if we have the station yet
                distance=vincenty((latitude, longitude), fslod[station]).km    # distance to the station
                dist=distance
                if distance > 150.0:
                    print "distcheck: ", distance, data
                elif distance > fsmax[station]: # if higher distance
                    fsmax[station]=distance     # save the new distance
                if altim > fsalt[station]:  	# if higher altitude
                    fsalt[station]=altim    	# save the new altitude
            if altim > tmaxa:
                tmaxa = altim               	# maximum altitude for the day
                tmaxt = hora                	# and time
                tmid  = id                  	# who did it
                tmsta = station             	# station capturing the max altitude
            if prt:
                print 'Parsed data: POS: ', longitude, latitude, altitude,' Speed:',speed,' Course: ',course,' Path: ',path,' Type:', type
                print roclimb, rot, sensitivity, gps, uniqueid, dist, extpos
            # write the DB record
            addcmd="insert into OGNDATA values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
            curs.execute(addcmd, (id, dte, hora, station, latitude, longitude, altim, speed, course, roclimb, rot,sensitivity, gps, uniqueid, dist, extpos))
            cin +=1                             # one more record read
        

except KeyboardInterrupt:
    print "Keyboard input received, ignore"
    pass

print 'Counters:', cin, cout                # report number of records read and files generated
shutdown(sock, datafile, tmaxa, tmaxt,tmid)
print "Exit now ..."
exit(1)



