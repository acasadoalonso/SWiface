<?php

include "auth.inc.php";

if (auth($_GET["username"],$_GET["cpassword"])) {
  print "{version}1.3{/version}";
  print "{date}".date("Ymd")."{/date}";
  print "{time}".time()."{/time}";
} else {
  print "Invalid authentication!";
}

?>
