<?php
include "auth.inc.php";

# TODO: check version

#if (auth($_GET["username"],$_GET["cpassword"])) { 
if (true) { 
  foreach(scandir("cuc") as $filename) {
    if(!preg_match('/\.cuc$/i',$filename)) {continue;}
    $filecontent = file_get_contents('cuc/'.$filename);
    if (preg_match('/\nTitle=(.+?)\r/',$filecontent, $matches)) {
      #print ">$filename ".utf8_encode($matches[1])."<\n";
      #print "{contestname}".$filename."{/contestname}{contestdisplayname}".utf8_encode($matches[1])."{/contestdisplayname}{datadelay}15{/datadelay}{utcoffset}+01:00{/utcoffset}\n";
      print "{contestname}".$filename."{/contestname}{contestdisplayname}".utf8_encode($matches[1])."{/contestdisplayname}{datadelay}15{/datadelay}{utcoffset}+01:00{/utcoffset}\n";
      print "{countrycode}FR{/countrycode}{site}Challes les eaux{/site}{fromdate}20001405{/fromdate}{todate}20990912{/todate}{lat}44.1959{/lat}{lon}5.98849{/lon}{alt}{/alt}\n";
    }
  }
// {contestname}FAIGP2005{/contestname}{contestdisplayname}1st FAI Grand PrixMondial{/contestdisplayname}{datadelay}15{/datadelay}{utcoffset}+01:00{/utcoffset}
// {countrycode}FR{/countrycode}{site}St. Auban{/site}{fromdate}20050903{/fromdate}
// {todate}20050912{/todate}{lat}44.1959{/lat}{lon}5.98849{/lon}{alt}{/alt}
// {contestname}GawlerGrandPrix{/contestname}{contestdisplayname}Australian Gliding GrandPrix{/contestdisplayname}{datadelay}6{/datadelay}{utcoffset}+10:30{/utcoffset}
// {countrycode}AU{/countrycode}{site}Gawler{/site}{fromdate}20061228{/fromdate}
// {todate}20070106{/todate}{lat}-34.6{/lat}{lon}138.71{/lon}{alt}48{/alt}
} else {
  print "Invalid authentication!";
}

?>
