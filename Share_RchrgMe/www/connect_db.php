<?php
require('../../../config/connect_params.php');

// Define the database
 $dbname = "rpwr_dev";
 $host = "dj859422-001.eu.clouddb.ovh.net";
 $user = "rchrgme_rwd";
 $password = "Pwd2DbSvc4Actions";
 $dbname = "rpwr_dev";
 $port = "35882";
$dbconn = pg_connect("host=$host dbname=$dbname user=$user password=$password port=$port sslmode=require")
    or die('Could not connect: ' . pg_last_error());


$stat = pg_connection_status($dbconn);

// Indicates if the database is connected
$IsDBConnected=false;

if($stat === PGSQL_CONNECTION_OK) 
	{$IsDBConnected=true;}
?>