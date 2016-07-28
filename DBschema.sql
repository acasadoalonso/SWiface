CREATE TABLE RECEIVERS (idrec char(6) UNIQUE, desc char(20), lati REAL, longi REAL, alti REAL);
CREATE TABLE OGNDATA (idflarm char(6) , date char(6), time char(6), station char(6), latitude float, longitude float, altitude int, speed float, course int, roclimb int, rot float, sensitivity float, gps char(6), uniqueid char(10), distance float, extpos char (5));
CREATE TABLE GLIDERS (idglider char(9) UNIQUE, registration char(6), cn char(3), type TEXT,  source char(1), flarmtype char(1));
CREATE INDEX OGNDIDX on OGNDATA (idflarm, date);
CREATE UNIQUE INDEX RECEIVERSIDX on RECEIVERS (idrec);
CREATE UNIQUE INDEX GLIDERIDX on GLIDERS (idglider);
CREATE VIEW OGNDATAREG as select *, (select registration from GLIDERS where idglider = idflarm), (select desc from RECEIVERS where station = idrec)  from OGNDATA;
