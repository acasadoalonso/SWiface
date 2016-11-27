<?php

define('BIRD', 'Dodo bird');

// Parse without sections
$ini_array = parse_ini_file("/etc/local/SWSconfig.ini");
print_r($ini_array);
echo $ini_array['DBpath'];
echo "\n";
// Parse with sections
$ini_array = parse_ini_file("/etc/local/SWSconfig.ini", true);
print_r($ini_array);

?>
