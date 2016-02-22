<?php

include "auth.inc.php";
include "sql.php";

function epoch2time($epochtime) {
  $date = new DateTime("@$epochtime");
  return $date->format("YmdHis");
}


# TODO: check version

if (auth($_GET["username"],$_GET["cpassword"])) {
  if (isset($_GET["querytype"]) && $_GET["querytype"] == "getintfixes") {

    $result = "{datadelay}5{/datadelay}\n";
    #<tracker id>,<timestamp>,<latitude>,<longitude>,<altitude>,<status>
    #$result .= "DDA42B,20061230045824,-34.60305,138.72063,49.0,0\n";
    
    $dbh= Database::connect();
    $sql = 'SELECT tim,lat,lon,alt FROM liveall WHERE fid="'.$_GET["trackerid"].'" AND tim>'.strtotime($_GET["starttime"]).' AND tim<'.strtotime($_GET["endtime"]);

    #print "$sql\n";
    $sqlresult= $dbh->query($sql);

    while($raw = $sqlresult->fetch()) {
       $result .= $_GET["trackerid"].','.epoch2time($raw["tim"]).','.$raw["lat"].','.$raw["lon"].','.$raw["alt"].",1\n";
    }
    
    Database::disconnect();


    if ($_GET["compression"] == "gzip") {
      print gzencode($result);
      #print $result;
    } else {
      print $result;
    }
  } else {
    print "Invalid query!";
  }
} else {
  print "Invalid authentication!";
}

?>

