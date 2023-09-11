#!/usr/bin/python3
from parserfuncs import SRSSgetjsondata, getinfoairport
import config
#
#	get the sunrise/sunset data
#

#
#	get the sunrise/sunset data
#
if getinfoairport (config.location_name) != None:
   print(getinfoairport (config.location_name))
   location_latitude =  str(getinfoairport (config.location_name)['lat'])
   location_longitude = str(getinfoairport (config.location_name)['lon'])
   
else:
   location_latitude=config.location_latitude
   location_longitude=config.location_longitude
print("Location coordinates:", location_latitude, location_longitude, "at: ", config.location_name)

lat=location_latitude
lon=location_longitude
timeepoc=SRSSgetjsondata(str(lat), str(lon), prt=False)

print(timeepoc,config.DBpath+config.APP+".sunset" )
sunsetfile = open (config.DBpath+config.APP+".sunset", 'w')         # create a file just to mark that we are alive
sunsetfile.write(str(timeepoc)+"\n")                                # write the time as control
sunsetfile.close()                                                  # close the alive file
