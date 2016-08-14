
#-------------------------------------
# OGN-Silent Wings interface --- Settings 
#-------------------------------------
#
#-------------------------------------
# Setting values
#-------------------------------------
#
import socket
hostname=socket.gethostname()
APRS_SERVER_HOST = 'aprs.glidernet.org'
APRS_SERVER_PORT = 14580
APRS_USER1     = 'SWIface'
APRS_USER2     = 'SWChile'
APRS_PASSCODE1 = 28080  						# See http://www.george-smart.co.uk/wiki/APRS_Callpass
APRS_PASSCODE2 = 28593  						# See http://www.george-smart.co.uk/wiki/APRS_Callpass
#APRS_FILTER_DETAILS = "filter r/+42.12/+0.48/225\n " 			# Benabarre center and covering the QSGP competition area, up to Pamplona
APRS_FILTER_DETAILS1 = "filter r/+42.12/+0.48/225 r/-33.12/-70.48/800 \n "  # two areas
APRS_FILTER_DETAILS2 = "filter r/-33.12/-70.48/800 \n "                # one areas
# ----------------------------------------- #
AFD={"SWserver": APRS_FILTER_DETAILS1, \
     "SW_Chile": APRS_FILTER_DETAILS2, \
    }
APUSR={"SWserver": APRS_USER1, \
       "SW_Chile": APRS_USER2, \
    }
APASS={"SWserver": APRS_PASSCODE1, \
       "SW_Chile": APRS_PASSCODE2, \
    }

APRS_USER           = APUSR[hostname]
APRS_PASSCODE       = APASS[hostname]  
APRS_FILTER_DETAILS = AFD[hostname]
# ----------------------------------------- #
									# Check that APRS_USER and APRS_PASSCODE are set
assert len(APRS_USER) > 3 and len(str(APRS_PASSCODE)) > 0, 'Please set APRS_USER and APRS_PASSCODE in settings.py.'
									# aprs.glidernet.org on port 14580.
FLOGGER_LATITUDE, FLOGGER_LONGITUDE = '+42.12', '+0.48'			# airport location for the sunrise/sunset
FLOGGER_MIN_FLIGHT_TIME = "0:5:0" 					# hh:mm:ss
FLOGGER_KEEPALIVE_TIME = 900 						# Interval in seconds for sending tcp/ip keep alive on socket connection


FILTER_LATI1 = 42.0 							# further filteering for latitude
FILTER_LATI2 = 43.0 							# further filteering for latitude
FILTER_LATI3 = -30.0 							# further filteering for latitude
FILTER_LATI4 = -36.0 							# further filteering for latitude

DBpath=r"/nfs/OGN/SWdata/"						# data directory
# MySQLdb settings
# --------------------------------------#
MySQL=True
DBhost   ="casadonfs"
DBuser   ="ogn"
DBpasswd ="ogn"
DBname   ="SWIFACE"
# --------------------------------------#
