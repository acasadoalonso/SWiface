# SWIface #

This repo contains the interface between the [Silent Wings](http://www.silentwings.no) either Studio or Viewer with the [OGN network](http://wiki.glidernet.org).

The main task is to collect all the **OGN APRS** data for a defined competition area and store it on a [SQLITE 3](https://sqlite.org) or [MySQL](https://www.mysql.com/products/) database.

File  |  Description
---- | ----
SWiface.py | 		Is the data collector. It gathers all the fixes on the competition area until the sunset
DBcreate.py |		Script to create the SWiface database, using the DBschema.sql file
DBschema.sql |		Database schema used in this application
libfap.py	|	APRS parser routine
parserfuncs.py	|	The set of routines to extract the main data from the APRS packets
kglid.py	|	The list of known gliders, this list is generated weekly from the [OGN device data base](http://wiki.glidernet.org/ddb) 
settings.py	|	The settings used by this application. You need to define here if your are using MySQL or not and the name of the user/password and host

Currently the system is running on a [Raspberry Pi 3](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/) with a HDD SDD of 128 Gb, using [Raspbian Jessie](https://www.raspberrypi.org/downloads/raspbian/) distro. The MySQL version uses a [Oracle's MySQL](https://www.oracle.com/mysql/index.html) database hosted on a WDC Mirror nas/nfs server. 

For any bug please report it thru the GitHub account, open an issue and I will try to solve it.

**Angel Casado**

[acasado (at) acm.org](acasado (at) acm.org)
