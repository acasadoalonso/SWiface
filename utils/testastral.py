from parserfuncs import *                 # the ogn/ham parser functions
from datetime import date, datetime, timezone, timedelta
import pytz
import time
import astral, astral.sun
# --------------------------------------#
if getinfoairport ("KUVA") != None:
   info=getinfoairport ("KUVA")
   print(info)
   latitude = info['lat']
   longitude = info['lon']
   
print("Location coordinates:", latitude, longitude)



altitude = 0
tz_kuva = pytz.timezone('America/Chicago')
tz_utc = pytz.timezone('UTC')
tz_name = 'America/Chicago'
city=info['city']
country=info['country']
tz=info['tz']
print('====== astral ======')
l = astral.LocationInfo(city, country, tz, latitude, longitude)
print((
    f"Information for {l.name}/{l.region}\n"
    f"Timezone: {l.timezone}\n"
    f"Latitude: {l.latitude:.02f}; Longitude: {l.longitude:.02f}\n"
))
s = astral.sun.sun(l.observer, date=date.today())
print(s['sunrise'].astimezone(tz_kuva), "local")
print(s['sunset'].astimezone(tz_kuva), "local")
print(s['dusk'].astimezone(tz_kuva), "local")
print(s['dusk'].astimezone(tz_utc), "UTC")
print(s['dusk'], "UTC")
