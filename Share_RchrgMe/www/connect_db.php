<?php
require('../../../config/connect_params.php');

// Define the database
 $dbname = "akuvitBD";
 $host = "akuvitpostgresql.postgres.database.azure.com";
 $user = "akuvitpostgresql@akuvitpostgresql";
 $password = "Achrafkarboul123456";
 $port = "5432";
$dbconn = pg_connect("host=$host dbname=$dbname user=$user password=$password port=$port sslmode=require")
    or die('Could not connect: ' . pg_last_error());


$stat = pg_connection_status($dbconn);

// Indicates if the database is connected
$IsDBConnected=false;

if($stat === PGSQL_CONNECTION_OK) 
	{$IsDBConnected=true;}
?>
