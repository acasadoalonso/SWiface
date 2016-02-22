<?php
class Database
{
    private static $dbName = 'YourDBName' ;
    private static $dbHost = 'localhost' ;
    private static $dbUsername = 'YourDBUserName';
    private static $dbUserPassword = 'YourDBPassword';
     
    private static $cont  = null;
     
    public function __construct() {
        die('Init function is not allowed');
    }
     
    public static function connect()
    {
       // Only one connection allowed through whole application
       if ( null == self::$cont )
       {     
        try
        {
          self::$cont =  new PDO( "mysql:host=".self::$dbHost.";"."dbname=".self::$dbName, self::$dbUsername, self::$dbUserPassword);
          self::$cont->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION); 
        }
        catch(PDOException $e)
        {
          echo 'Connection failed: ' . $e->getMessage(); 
        }
       }
       return self::$cont;
    }
     
    public static function disconnect()
    {
        self::$cont = null;
    }
}


/* utilisation:
include 'sql.php';
$dbh= Database::connect()
$sql = 'SELECT * FROM customers ORDER BY id DESC';
$result= $dbh->query($sql);
Database::disconnect();

*/
