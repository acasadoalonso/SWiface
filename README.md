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
SWSconfig.ini	|	The settings used by this application. You need to define here if your are using MySQL or not and the name of the user/password and host, This file is in /etc/local

Originally  the system was running on a [Raspberry Pi 3](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/) with a HDD SDD of 128 Gb, using [Raspbian Jessie](https://www.raspberrypi.org/downloads/raspbian/) distro. The MySQL version uses a [Oracle's MySQL](https://www.oracle.com/mysql/index.html) database hosted on a WDC Mirror nas/nfs server. 
Nowadays the system is running in a [Intel NUC] (http://www.intel.com/nuc) under [Ubuntu 16.04.2 LTS (Xenial)] (http://www.ubuntu.com) and also running under a virtual machine [VirtualBox] (http://www.virtualbox.org) and [Vagrant] (https://www.vagrantup.com/) in a Windows 10 environment.

For any bug please report it thru the GitHub account, open an issue and I will try to solve it.

**Angel Casado**

[acasado (at) acm.org](acasado (at) acm.org)
