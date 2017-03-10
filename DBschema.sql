CREATE TABLE OGNDATA (idflarm char(9) , date char(6), time char(6), station char(6), latitude float, longitude float, altitude int, speed float, course int, roclimb int, rot float, sensitivity float, gps char(6), uniqueid char(9), distance float, extpos char (5), source char(4));
CREATE TABLE GLIDERS (idglider char(9) UNIQUE, registration char(6), cn char(3), type TEXT,  source char(1), flarmtype char(1));
CREATE TABLE RECEIVERS (idrec char(9) UNIQUE, descri char(20), lati REAL, longi REAL, alti REAL);
CREATE INDEX OGNDIDX on OGNDATA (idflarm, date);
CREATE UNIQUE INDEX GLIDERIDX on GLIDERS (idglider);
CREATE VIEW OGNDATAREG as select *, (select registration from GLIDERS where idglider = idflarm), (select descri from RECEIVERS where station = idrec)  from OGNDATA;
--
-- Table structure for table `TRKDEVICES`
--

CREATE TABLE `TRKDEVICES` (
  `id` varchar(16) NOT NULL,
  `owner` varchar(64) NOT NULL,
  `spotid` varchar(36) NOT NULL,
  `spotpasswd` varchar(16) DEFAULT NULL,
  `compid` varchar(3) NOT NULL,
  `model` varchar(16) NOT NULL,
  `registration` varchar(9) NOT NULL,
  `active` tinyint(1) NOT NULL,
  `devicetype` varchar(6) NOT NULL DEFAULT 'SPOT',
  `flarmid` varchar(9) DEFAULT NULL
) ;


CREATE UNIQUE INDEX TRKDEVICESIDX  on TRKDEVICES (id);
