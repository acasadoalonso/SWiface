CREATE TABLE OGNDATA (idflarm char(9) , date char(6), time char(6), station char(6), latitude float, longitude float, altitude int, speed float, course int, roclimb int, rot float, sensitivity float, gps char(6), uniqueid char(16), distance float, extpos char (5), source char(4));
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
--
-- Database: `SWIFACE`
--

DELIMITER $$
--
-- Functions
--
CREATE FUNCTION `GETBEARING` (`lat1` DOUBLE, `lon1` DOUBLE, `lat2` DOUBLE, `lon2` DOUBLE) RETURNS DOUBLE NO SQL
    DETERMINISTIC
BEGIN
	DECLARE bearing FLOAT;
    SET bearing= (360.0 + 
      DEGREES(ATAN2(
       SIN(RADIANS(lon2-lon1))*COS(RADIANS(lat2)),
       COS(RADIANS(lat1))*SIN(RADIANS(lat2))-SIN(RADIANS(lat1))*COS(RADIANS(lat2))*
            COS(RADIANS(lon2-lon1))
      ))
     ) % 360.0;
     RETURN bearing;
END$$

CREATE  FUNCTION `GETBEARINGROSE` (`lat1` DOUBLE, `lon1` DOUBLE, `lat2` DOUBLE, `lon2` DOUBLE) RETURNS VARCHAR(5) CHARSET utf8 NO SQL
    DETERMINISTIC
BEGIN
	DECLARE bearing FLOAT;
	DECLARE bearingRose VARCHAR(5);
    SET bearing= (360.0 + 
      DEGREES(ATAN2(
       SIN(RADIANS(lon2-lon1))*COS(RADIANS(lat2)),
       COS(RADIANS(lat1))*SIN(RADIANS(lat2))-SIN(RADIANS(lat1))*COS(RADIANS(lat2))*
            COS(RADIANS(lon2-lon1))
      ))
     ) % 360.0;
     SET bearingRose='N';
     IF bearing>=0 AND bearing<11.5 THEN SET bearingRose='N';
     ELSEIF bearing>=11.5 AND bearing<34 THEN SET bearingRose='NNE';
     ELSEIF bearing>=34 AND bearing<56.5 THEN SET bearingRose='NE';
     ELSEIF bearing>=56.5 AND bearing<79 THEN SET bearingRose='ENE';
     ELSEIF bearing>=79 AND bearing<101.5 THEN SET bearingRose='E';
     ELSEIF bearing>=101.5 AND bearing<124 THEN SET bearingRose='ESE';
     ELSEIF bearing>=124 AND bearing<146.5 THEN SET bearingRose='SE';
     ELSEIF bearing>=146.5 AND bearing<169 THEN SET bearingRose='SSE';
     ELSEIF bearing>=169 AND bearing<191.5 THEN SET bearingRose='S';
     ELSEIF bearing>=191.5 AND bearing<214 THEN SET bearingRose='SSW';
     ELSEIF bearing>=214 AND bearing<236.5 THEN SET bearingRose='SW';
     ELSEIF bearing>=236.5 AND bearing<259 THEN SET bearingRose='WSW';
     ELSEIF bearing>=259 AND bearing<281.5 THEN SET bearingRose='W';
     ELSEIF bearing>=281.5 AND bearing<304 THEN SET bearingRose='WNW';
     ELSEIF bearing>=304 AND bearing<326.5 THEN SET bearingRose='NW';
     ELSEIF bearing>=326.5 AND bearing<349 THEN SET bearingRose='NNW';
     ELSE SET bearingRose='N';
     END IF;
     
     RETURN bearingRose;
END$$

CREATE  FUNCTION `GETDISTANCE` (`deg_lat1` FLOAT, `deg_lng1` FLOAT, `deg_lat2` FLOAT, `deg_lng2` FLOAT) RETURNS FLOAT BEGIN 
  DECLARE distance FLOAT;
  DECLARE delta_lat FLOAT; 
  DECLARE delta_lng FLOAT; 
  DECLARE lat1 FLOAT; 
  DECLARE lat2 FLOAT;
  DECLARE a FLOAT;

  SET distance = 0;

  
  SET delta_lat = radians(deg_lat2 - deg_lat1); 
  SET delta_lng = radians(deg_lng2 - deg_lng1); 
  SET lat1 = radians(deg_lat1); 
  SET lat2 = radians(deg_lat2); 

  
  SET a = sin(delta_lat/2.0) * sin(delta_lat/2.0) + sin(delta_lng/2.0) * sin(delta_lng/2.0) * cos(lat1) * cos(lat2); 
  SET distance = 3956.6 * 2 * atan2(sqrt(a),  sqrt(1-a)); 

  RETURN distance;
END$$

DELIMITER ;

