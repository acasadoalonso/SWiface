
#-------------------------------------
# OGN-Silent Wings interface --- Settings 
#-------------------------------------
#
#-------------------------------------
# Setting values
#-------------------------------------
#

APRS_SERVER_HOST = 'aprs.glidernet.org'
APRS_SERVER_PORT = 14580
APRS_USER = 'SWIface'
# APRS_PASSCODE = -1   #Read only

APRS_PASSCODE = 28080  							# See http://www.george-smart.co.uk/wiki/APRS_Callpass
APRS_FILTER_DETAILS = "filter r/+42.12/+0.48/225\n " 			# Benabarre center and covering the QSGP competition area, up to Pamplona
									# Check that APRS_USER and APRS_PASSCODE are set
assert len(APRS_USER) > 3 and len(str(APRS_PASSCODE)) > 0, 'Please set APRS_USER and APRS_PASSCODE in settings.py.'
									# aprs.glidernet.org on port 14580.
FLOGGER_DB_SCHEMA = "flogger_schema-0.0.1.sql"
FLOGGER_LATITUDE, FLOGGER_LONGITUDE = '+42.12', '+0.48'			# airport location for the sunrise/sunset
FLOGGER_MIN_FLIGHT_TIME = "0:5:0" 					# hh:mm:ss
FLOGGER_KEEPALIVE_TIME = 900 						# Interval in seconds for sending tcp/ip keep alive on socket connection

# mapping of the last position know of each glider

lastp_lati={"LECD" : +42.38695}						# the dummy competitor
lastp_long={"LECD" : +1.86843}						# the dummy competitor
lastp_alti={"LECD" : +1105.8144}					# the dummy competitor

FILTER_LATI1 = 42.0 							# further filteering for latitude
FILTER_LATI2 = 43.0 							# further filteering for latitude
DBpath=r"/nfs/OGN/SWdata/"						# data directory
