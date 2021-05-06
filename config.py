#-------------------------------------
# OGN-SWS Spain interface --- Settings
#-------------------------------------
#
#-------------------------------------
# Setting values
#-------------------------------------
#
import socket
import os
from configparser import ConfigParser
configdir=os.getenv('CONFIGDIR')
if configdir == None:
	configdir='/etc/local/'
configfile=configdir+'SWSconfig.ini'
hostname = socket.gethostname()
processid = str(os.getpid())
if os.path.isfile(configfile):
	
	cfg=ConfigParser()		# get the configuration parameters
	cfg.read(configfile)		# reading it for the configuration file
else:
	print ("Config file: ", configfile, " not found \n")
	exit(-1)
APRS_SERVER_HOST        = cfg.get    ('APRS', 'APRS_SERVER_HOST').strip("'").strip('"')
APRS_SERVER_PORT        = int(cfg.get('APRS', 'APRS_SERVER_PORT'))
APRS_USER               = cfg.get    ('APRS', 'APRS_USER').strip("'").strip('"')
APRS_PASSCODE           = int(cfg.get('APRS', 'APRS_PASSCODE'))                 # See http://www.george-smart.co.uk/wiki/APRS_Callpass
APRS_FILTER_DETAILS     = cfg.get    ('APRS', 'APRS_FILTER_DETAILS').strip("'").strip('"')
APRS_FILTER_DETAILS     = APRS_FILTER_DETAILS + '\n '

location_latitude       = cfg.get('location', 'location_latitude').strip("'").strip('"')
location_longitude      = cfg.get('location', 'location_longitud').strip("'").strip('"')
FLOGGER_LATITUDE        = cfg.get('location', 'location_latitude').strip("'").strip('"')
FLOGGER_LONGITUDE       = cfg.get('location', 'location_longitud').strip("'").strip('"')

FILTER_LATI1            = float(cfg.get('filter', 'FILTER_LATI1'))
FILTER_LATI2            = float(cfg.get('filter', 'FILTER_LATI2'))
FILTER_LATI3            = float(cfg.get('filter', 'FILTER_LATI3'))
FILTER_LATI4            = float(cfg.get('filter', 'FILTER_LATI4'))

# --------------------------------------#
try:
        prttext     = cfg.get('server', 'prt').strip("'")
        if     (prttext == 'False'):
                prt = False
        else:
                prt = True
except:
        prt         = True

try:
        cucFileLocation = cfg.get('server', 'cucFileLocation').strip("'").strip('"')
except:
        cucFileLocation = "/var/www/html/cuc/"

try:
	PIDfile         = cfg.get('server', 'pid').strip("'").strip('"')
except:
	PIDfile='/tmp/SWS.pid'

try:
	location_name   = cfg.get('location', 'location_name').strip("'").strip('"')
except:
	location_name   = ' '
#
# --------------------------------------#
try:
	SPOTtext        = cfg.get('location', 'SPOT').strip("'").strip('"')
except:
	SPOTtext='False'

try:
	LT24text        = cfg.get('location', 'LT24').strip("'").strip('"')
	LT24username    = cfg.get('location', 'LT24username').strip("'").strip('"')
	LT24password    = cfg.get('location', 'LT24password').strip("'").strip('"')
except:
	LT24text='False'
try:
	SPIDERtext      = cfg.get('location', 'SPIDER').strip("'").strip('"')
	SPIuser         = cfg.get('location', 'SPIuser').strip("'").strip('"')
	SPIpassword     = cfg.get('location', 'SPIpassword').strip("'").strip('"')
	SPISYSid        = cfg.get('location', 'SPISYSid').strip("'").strip('"')
except:
	SPIDERtext='False'
try:
	SKYLINEtext     = cfg.get('location', 'SKYLINE').strip("'").strip('"')
except:
	SKYLINEtext='False'
try:
	OGNTtext     = cfg.get('location', 'OGNT').strip("'").strip('"')
except:
	OGNTtext='False'

try:
	DDBhost     = cfg.get('server', 'DDBhost').strip("'")
except:
	DDBhost     = 'acasado.es'

try:
	DDBport     = cfg.get('server', 'DDBport').strip("'")
except:
	DDBport     = '60082'

try:
	DDBurl1     = cfg.get('server', 'DDBurl1').strip("'")
except:
	DDBurl1     = 'http://acasado.es:60082/download/?j=2'

try:
	DDBurl2     = cfg.get('server', 'DDBurl2').strip("'")
except:
	DDBurl2     = 'http://DDB.glidernet.org/download/?j=2'



DBpath                  = cfg.get('server', 'DBpath').strip("'").strip('"')
MySQLtext               = cfg.get('server', 'MySQL').strip("'").strip('"')
DBhost                  = cfg.get('server', 'DBhost').strip("'").strip('"')
DBuser                  = cfg.get('server', 'DBuser').strip("'").strip('"')
DBpasswd                = cfg.get('server', 'DBpasswd').strip("'").strip('"')
DBuserread              = cfg.get('server', 'DBuserread').strip("'").strip('"')
DBpasswdread            = cfg.get('server', 'DBpasswdread').strip("'").strip('"')
DBname                  = cfg.get('server', 'DBname').strip("'").strip('"')
# -------------------------------------------------------------------------------#
APP='SWS'
if (MySQLtext == 'True'):
        MySQL = True
else:
        MySQL = False
if (SPIDERtext == 'True'):
        SPIDER = True
else:
        SPIDER = False
if (SPOTtext == 'True'):
        SPOT = True
else:
        SPOT = False
if (LT24text == 'True'):
        LT24 = True
else:
        LT24 = False
if (SKYLINEtext == 'True'):
        SKYLINE = True
else:
        SKYLINE = False
if (OGNTtext == 'True'):
        OGNT = True
else:
        OGNT = False
# --------------------------------------#
assert len(APRS_USER) > 3 and len(str(APRS_PASSCODE)) > 0, 'Please set APRS_USER and APRS_PASSCODE in settings.py.'
 
# --------------------------------------#
						# report the configuration paramenters
print("Config file used:    ",                  configfile, hostname, processid)
print("Config server values:",                  "MySQL =", MySQL, DBhost, DBuser, DBname, DBpath, cucFileLocation)
print("Config APRS values:  ",                  APRS_SERVER_HOST, APRS_SERVER_PORT, APRS_USER, APRS_PASSCODE, APRS_FILTER_DETAILS)
print("Config location :    ", 			location_name, location_latitude, location_longitude, "SPIDER=", SPIDER, "SPOT=", SPOT, "LT24=", LT24, "SKYLINE=", SKYLINE, "OGNtracker=", OGNT)
# --------------------------------------#

