-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: May 31, 2017 at 11:15 PM
-- Server version: 5.1.56
-- PHP Version: 5.4.16

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: 'SWIFACE'
--

DELIMITER $$
--
-- Functions
--
DROP FUNCTION IF EXISTS `GETBEARING`$$
CREATE  FUNCTION `GETBEARING`(`lat1` DOUBLE, `lon1` DOUBLE, `lat2` DOUBLE, `lon2` DOUBLE) RETURNS double
    NO SQL
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

DROP FUNCTION IF EXISTS `GETBEARINGROSE`$$
CREATE  FUNCTION `GETBEARINGROSE`(`lat1` DOUBLE, `lon1` DOUBLE, `lat2` DOUBLE, `lon2` DOUBLE) RETURNS varchar(5) CHARSET utf8
    NO SQL
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

DROP FUNCTION IF EXISTS `GETDISTANCE`$$
CREATE  FUNCTION `GETDISTANCE`(`deg_lat1` FLOAT, `deg_lng1` FLOAT, `deg_lat2` FLOAT, `deg_lng2` FLOAT) RETURNS float
BEGIN 
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

-- --------------------------------------------------------

--
-- Table structure for table 'GLIDERS'
--

DROP TABLE IF EXISTS GLIDERS;
CREATE TABLE IF NOT EXISTS GLIDERS (
  idglider char(9) DEFAULT NULL,
  registration char(9) DEFAULT NULL,
  cn char(3) DEFAULT NULL,
  `type` text,
  `source` char(1) DEFAULT NULL,
  flarmtype char(1) DEFAULT NULL,
  UNIQUE KEY idglider (idglider),
  UNIQUE KEY GLIDERIDX (idglider)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table 'OGNDATA'
--

DROP TABLE IF EXISTS OGNDATA;
CREATE TABLE IF NOT EXISTS OGNDATA (
  idflarm char(9) DEFAULT NULL,
  `date` char(6) DEFAULT NULL,
  `time` char(6) DEFAULT NULL,
  station char(9) DEFAULT NULL,
  latitude float DEFAULT NULL,
  longitude float DEFAULT NULL,
  altitude int(11) DEFAULT NULL,
  speed float DEFAULT NULL,
  course int(11) DEFAULT NULL,
  roclimb int(11) DEFAULT NULL,
  rot float DEFAULT NULL,
  sensitivity float DEFAULT NULL,
  gps char(6) DEFAULT NULL,
  uniqueid char(15) DEFAULT NULL,
  distance float DEFAULT NULL,
  extpos char(5) DEFAULT NULL,
  `source` varchar(4) NOT NULL DEFAULT 'OGN' COMMENT 'The source of data',
  KEY IDXDATETIME (`date`,`time`),
  KEY IDXTIME (`time`),
  KEY IDXOGND (idflarm,`date`,`time`),
  KEY IDFLRAM (idflarm)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Fixes from the gliders';

-- --------------------------------------------------------

--
-- Table structure for table 'RECEIVERS'
--

DROP TABLE IF EXISTS RECEIVERS;
CREATE TABLE IF NOT EXISTS RECEIVERS (
  idrec char(9) DEFAULT NULL,
  descri char(30) DEFAULT NULL,
  lati double DEFAULT NULL,
  longi double DEFAULT NULL,
  alti double DEFAULT NULL,
  UNIQUE KEY idrec (idrec),
  UNIQUE KEY RECEIVERSIDX (idrec)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='OGN Stations ';

-- --------------------------------------------------------

--
-- Table structure for table 'TRKDEVICES'
--

DROP TABLE IF EXISTS TRKDEVICES;
CREATE TABLE IF NOT EXISTS TRKDEVICES (
  id varchar(16) NOT NULL,
  `owner` varchar(64) NOT NULL,
  spotid varchar(36) NOT NULL,
  spotpasswd varchar(16) DEFAULT NULL,
  compid varchar(3) NOT NULL,
  model varchar(16) NOT NULL,
  registration varchar(9) NOT NULL,
  active tinyint(1) NOT NULL,
  devicetype varchar(6) NOT NULL DEFAULT 'SPOT',
  flarmid varchar(9) DEFAULT NULL COMMENT 'Flarmid to link',
  UNIQUE KEY id (id),
  KEY spotid (spotid)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

