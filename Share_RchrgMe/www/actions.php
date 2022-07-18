<?php
// Datbase connection management
// Datbase connection management

require('./connect_db.php');


// This function verifies if a charging point exists and if it's the case send all parameters for setup
function register($dbconn, $chp_id)
{
	// Query the database to check if the charging point exists and gets policy
	$QueryString="	Select chp.chp_code as chp_code, plc.plc_free_duration_mn as free_duration_mn,
										plc.plc_max_duration_mn as max_duration_mn,
										plc.plc_nb_max_chrg_day as nb_max_chrg_day
								From chp_charging_point chp
										Inner Join stc_charging_station stc On stc.stc_id = chp.stc_id
										Inner Join plc_policies plc On plc.csi_id = stc.csi_id
								Where plc.plc_top_default=1
								And chp.chp_id = '$chp_id'";
								
	$policy = pg_query($dbconn, $QueryString);

	if (!$policy) {
	  echo "<br>There is a possible error, no policy found.\n";
	  exit;
	}

	// Query the database to get application messages
	$QueryString="Select msg_code as Code, msg_label as Label From msg_app_messages Where msg_language=(Select chp_language From chp_charging_point where chp_id ='$chp_id')";
								
	$msgs = pg_query($dbconn, $QueryString);

	if (!$msgs) {
	  echo "<br>There is a possible error, no messages found.\n";
	  exit;
	}

	// Fetch data to build the JSON
	$arr = pg_fetch_array($policy, NULL, PGSQL_ASSOC); // Start by adding the params for the policy

	//Build an array for messages
	$Idx=0;
	while ($arr_msg=pg_fetch_array($msgs, NULL, PGSQL_ASSOC))
	{
	  $arr_msgs[$Idx]=$arr_msg;
	  $Idx++;
	}

	// Add messages to global array
	$arr['msgs']=$arr_msgs;

	// Encode array to json
	header("Content-Type=> application/json");
	return json_encode($arr);
 }

// This function verifies if a charging point exists and if it's the case send all parameters for setup
function setavailable($dbconn, $chp_id)
{
	// Query the database to check if the charging point exists and gets policy
	$QueryString="Update chp_charging_point Set chp_top_available=1 Where chp_id = '$chp_id'";
								
	$result = pg_query($dbconn, $QueryString);

	if (!$result) {
	  echo "<br>There is a possible error, unable to set as available.\n";
	  exit;
	}

	// Query the database to get application messages
	$QueryString="Select cli_id as ID_Client, floor(extract(epoch from (chg_start_date - Now()))) As Start_Into
						From chg_charges
						Where chg_top_reservation = 1
						And chg_start_date > Now()
						And DATE_PART('day', Now() - chg_start_date) <=1
						And chp_id = '$chp_id'
						Order by chg_start_date Asc Limit 1)";
								
	$NextCli = pg_query($dbconn, $QueryString);

	if (!$msgs) 
	{
	  exit ("None");
	}

	// Fetch data to build the JSON
	$arr = pg_fetch_array($NextCli, NULL, PGSQL_ASSOC); // Start by adding the params for the policy

	// Encode array to json
	header("Content-Type=> application/json");
	return json_encode($arr);
 }

?>