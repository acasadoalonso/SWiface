from parserfuncs import *                 # the ogn/ham parser functions
# --------------------------------------#
if getinfoairport ("KUVA") != None:
   print(getinfoairport ("KUVA"))
   location_name="KUVA"
   latitude = getinfoairport (location_name)['lat']
   longitude = getinfoairport (location_name)['lon']
   
print("Location coordinates:", latitude, longitude)


from datetime import date, datetime, timezone, timedelta
import pytz
import time
from suntime import Sun, SunTimeException
from suntimes import SunTimes
#import sunriset
import astral, astral.sun

altitude = 0
tz_kuva = pytz.timezone('America/Chicago')
tz_name = 'America/Chicago'
for_date = date(2024, 8, 12)
print('====== suntime ======')
abd = for_date
sun = Sun(latitude, longitude)
today_sr = sun.get_sunrise_time()
today_ss = sun.get_sunset_time()
print(today_sr.astimezone(tz_kuva))
print(today_ss.astimezone(tz_kuva))
print('====== suntimes ======')
sun2 = SunTimes(longitude=longitude, latitude=latitude, altitude=altitude)
day = datetime(for_date.year, for_date.month, for_date.day)
print(sun2.risewhere(day, tz_name))
print(sun2.setwhere(day, tz_name))
print('====== astral ======')
l = astral.LocationInfo('Uvalde', 'USA', tz_name, latitude, longitude)
print((
    f"Information for {l.name}/{l.region}\n"
    f"Timezone: {l.timezone}\n"
    f"Latitude: {l.latitude:.02f}; Longitude: {l.longitude:.02f}\n"
))
s = astral.sun.sun(l.observer, date=date.today())
print(s['sunrise'].astimezone(tz_kuva))
print(s['sunset'].astimezone(tz_kuva))
print(s['dusk'].astimezone(tz_kuva))
print(s['dusk'])
