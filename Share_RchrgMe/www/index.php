<?php
 //call actions page
//call actions page

 require('./actions.php');
 
 // Get params
 $action = $_GET['action'];
 $chp_id = $_GET['chpid'];
 
 // Check id the database is connected, if not inform and exit
if($IsDBConnected==false)
	{exit("<br>An error occurred when connecting to database!");}
else
{echo " ";}

// There is aconnection to the database
switch ($action) 
{
	case 'register':
		// Register charging point
		$Str=register($dbconn, $chp_id);
		echo $Str;
		break;
		
	case 'setavailable':
		//Define charging point as available
		$Str=setavailable($dbconn, $chp_id);
		echo $Str;
		break;
		
	case 'checkavailability':
		//Check availibility of charging points of the same site
		echo "<br>Check availibility of charging points of the same site.<br>";
		break;
		
	case 'checkuser':
		//Check if user can charge
		echo "<br>Check if user can charge.<br>";
		break;
		
	case 'startchrg':
		//Start charge for the user
		echo "<br>Start charge for the user.<br>";
		break;
		
	case 'UpdChrgStatus':
		//Update charge status
		echo "<br>Update charge status.<br>";
		break;
		
	case 'EndChrg':
		//End charge
		echo "End charge.<br>";
		break;
		
	default:
	   echo "<br>Unknown action to do !";
}
?>