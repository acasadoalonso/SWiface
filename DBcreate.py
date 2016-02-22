#!/usr/bin/python
#
from DBopen_db import opendb
import sqlite3
#-----------------------------------------------------------------
# Build flogger db using schema
#-----------------------------------------------------------------
#
cur = [0]    					# cur is mutable
schema="DBschema.sql"				# OGN database schema
r = opendb('DBschema.sql', cur)			# create the OGN database using the schema

conn=sqlite3.connect(r'SWiface.db')			# connect now with the created database
curs=conn.cursor()

#####################				# add now the preset values into stations and receivers

addcmd="insert into STATIONS values (?,?,?,?)"
curs.execute(addcmd, ('LELT',  '990101', 1.0, 0))
curs.execute(addcmd, ('LEOC',  '990101', 1.0, 0))
curs.execute(addcmd, ('LEFM',  '990101', 1.0, 0))
curs.execute(addcmd, ('LECI1', '990101', 1.0, 0))
curs.execute(addcmd, ('LECI2', '990101', 1.0, 0))
curs.execute(addcmd, ('LETP',  '990101', 1.0, 0))
curs.execute(addcmd, ('LECD',  '990101', 1.0, 0))
curs.execute(addcmd, ('LEIG',  '990101', 1.0, 0))
curs.execute(addcmd, ('MORA',  '990101', 1.0, 0))
curs.execute(addcmd, ('CREAL', '990101', 1.0, 0))

addcmd="insert into RECEIVERS values (?, ?, ?, ?, ?)"
curs.execute(addcmd, ('LELT',  'Lillo',                 39.71498, -3.31366, 2244.0))
curs.execute(addcmd, ('LEOC',  'Ocana',                 39.93543, -3.49672, 2427.0))
curs.execute(addcmd, ('LEFM',  'Fuentemilanos',         40.88903, -4.24122, 3372.0))
curs.execute(addcmd, ('LECI1', 'Santa Cilia',           42.56753, -0.72573, 2244.0))
curs.execute(addcmd, ('LECI2', 'San Juan de la Pena',   42.51146, -0.66187, 4215.0))
curs.execute(addcmd, ('LETP',  'Santo Tome del Puerto', 41.19410, -3.57732, 3736.0))
curs.execute(addcmd, ('LECD',  'La Cerdanya',           42.38695, +1.86843, 3628.0))
curs.execute(addcmd, ('LEIG',  'Igualada',              41.58666, +1.65250, 1122.0))
curs.execute(addcmd, ('MORA',  'Mora de Toledo',        39.68739, -3.77004, 2388.0))
curs.execute(addcmd, ('CREAL', 'Ciudad Real',           38.98252, -3.91249, 2112.0))
conn.commit()
						# print the preset values as a way to check it
curs.execute ('select * from STATIONS')
for row in curs.fetchall():
    print row
conn.commit()
curs.execute ('select * from RECEIVERS')
for row in curs.fetchall():
    print row

curs.execute ('select (select desc from RECEIVERS where idsta = idrec), mdist, malt from STATIONS')
for row in curs.fetchall():
    print row
           
print "Print dictionaries:"             
curs.execute('select * from STATIONS')
colnames = [desc[0] for desc in curs.description]
print "STATATIONS", colnames 
curs.execute('select * from RECEIVERS')
colnames = [desc[0] for desc in curs.description]
print "RECEIVERS", colnames
curs.execute('select * from OGNDATA')
colnames = [desc[0] for desc in curs.description]
print "OGNDATA", colnames
curs.execute('select * from GLIDERS')
colnames = [desc[0] for desc in curs.description]
print "GLIDERS", colnames
curs.execute('select * from METEO')
colnames = [desc[0] for desc in curs.description]
print "METEO", colnames
conn.commit()
conn.close()

