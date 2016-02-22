<?php

include "auth.inc.php";

# TODO: check version

if (auth($_GET["username"],$_GET["cpassword"])) {
  if (isset($_GET["contestname"])) {
    # TODO: manage contestname
    if (isset($_GET["date"])) {
      # TODO: remove bad chars frome name
      if (file_exists("cuc/".$_GET["contestname"])) {
        print file_get_contents("cuc/".$_GET["contestname"]);
      } else {
        # TODO: file not found
        print "File not found! cuc/".$_GET["contestname"];
      } 
    } else {
      # TODO: manage days list
      #print "{date}".date("Ymd")."{/date}{task}0{/task}{validday}1{/validday}";
      $cucfilecontent=file_get_contents("cuc/".$_GET["contestname"]);
      if (preg_match_all('/\nD(\d\d)(\d\d)(\d\d\d\d)/',$cucfilecontent, $matches,PREG_SET_ORDER)) {
        foreach ($matches as $val) {
          print "{date}".$val[3].$val[2].$val[1]."{/date}{task}0{/task}{validday}1{/validday}\n";
        }
      }
    }
  } else {
    print "Invalid contest!";
  }
} else {
  print "Invalid authentication!";
}

?>
