CREATE TABLE GLIDERS (idglider char(6) UNIQUE, registration char(6), cn char(3), type TEXT,  source char(1));
CREATE TABLE METEO (date char(6), time char (6), metstation char(4), rowdata TEXT NULL DEFAULT NULL, temp REAL, dewp REAL, winddir int, windspeed int, windgust int, visibility int, qnh REAL, cloud TEXT, fcat TEXT, wxstring TEXT);
CREATE TABLE OGNDATA (idflarm char(6) , date char(6), time char(6), station char(6), latitude float, longitude float, altitude int, speed float, course int, roclimb int, rot float, sensitivity float, gps char(6), uniqueid char(9), distance float, extpos char (5));
CREATE TABLE RECEIVERS (idrec char(6) UNIQUE, desc char(20), lati REAL, longi REAL, alti REAL);
CREATE TABLE STATIONS (idsta char(6) , date char(6), mdist float, malt int);
CREATE VIEW STASTA  as select idsta, (select desc from RECEIVERS where idrec=idsta), date, mdist, malt from STATIONS;
CREATE VIEW OGNDATAREG as select *, (select registration from GLIDERS where idglider = idflarm), (select desc from RECEIVERS where station = idrec)  from OGNDATA;
CREATE UNIQUE INDEX GLIDERIDX on GLIDERS (idglider);
CREATE UNIQUE INDEX METEOIDX on METEO ( date , time, metstation);
CREATE INDEX OGNDIDX on OGNDATA (idflarm, date);
CREATE UNIQUE INDEX RECEIVERSIDX on RECEIVERS (idrec);

