-- Creation du modèle pour la borne JDO(Free) et client JDO
-- Suppression des éléments crées
Delete From chg_charges 
Where cli_id in (Select cli_id From cli_client Where cli_name='José');

Delete from chp_charging_point
Where chp_id in (Select chp.chp_id
			  		From owr_owner owr
						Inner Join csi_charging_site csi On csi.owr_id = owr.owr_id		
				 		Inner Join stc_charging_station stc On stc.csi_id = csi.csi_id
						Inner Join chp_charging_point chp On chp.stc_id = stc.stc_id
				 	where owr_name='José');

Delete From plc_policies
Where plc_id in ( Select plc.plc_id
			  		From owr_owner owr
						Inner Join csi_charging_site csi On csi.owr_id = owr.owr_id		
						Inner Join plc_policies plc On plc.csi_id = csi.csi_id
				 	where owr_name='José');

Delete From stc_charging_station
Where stc_id in (Select stc.stc_id
			  		From owr_owner owr
						Inner Join csi_charging_site csi On csi.owr_id = owr.owr_id		
				 		Inner Join stc_charging_station stc On stc.csi_id = csi.csi_id
				 	where owr_name='José');

Delete from csi_charging_site
Where csi_id in (Select csi.csi_id
			  		From owr_owner owr
						Inner Join csi_charging_site csi On csi.owr_id = owr.owr_id		
				 	where owr_name='José');

Delete from chg_charges
Where cli_id in (Select cli_id From cli_client Where cli_name='José');

Delete From owr_owner where owr_name='José'; 

Delete From cli_client where cli_name='José';

-- Insertion des éléments
INSERT INTO owr_owner(owr_name) VALUES ('José');

Insert Into cli_client(cli_name, cli_id_vehicle, cli_vehicle_model, cli_bat_capacity_wh, cli_nominal_range_km)
Values ('José', 'XX-123-YY', 'E-GOLF', 36000, 250);

INSERT INTO csi_charging_site (owr_id, csi_description)
Select owr_id As owr_id, 'Site de test JDO' as csi_description 
From owr_owner where owr_name='José';

INSERT INTO stc_charging_station(csi_id, stc_location, stc_max_pwr_kwh)
Select csi_id As csi_id, 'Paris' As stc_location, 7 As stc_max_pwr_kwh
From csi_charging_site csi
		Inner Join owr_owner owr On owr.owr_id = csi.owr_id
where owr_name='José';

INSERT INTO plc_policies(csi_id, plc_label, plc_start_date, plc_free_duration_mn, plc_max_duration_mn, plc_nb_max_chrg_day, plc_cost_kwh, plc_top_default)
	
Select csi_id As csi_id, 
		'Politique par défaut' as plc_label, 
		to_date('20220101', 'YYYYMMDD') As plc_start_date, 
		1 as plc_free_duration_mn, 
		2 as plc_max_duration_mn, 
		1 as plc_nb_max_chrg_day, 
		0 as plc_cost_kwh, 
		1 as plc_top_default
From csi_charging_site csi
		Inner Join owr_owner owr On owr.owr_id = csi.owr_id
where owr_name='José'
Union All
Select csi_id as csi_id, 
		'Politique PRIVILEGE JDO' as plc_label, 
		'20220101' As plc_start_date, 
		2 as plc_free_duration_mn, 
		5 as plc_max_duration_mn, 
		2 as plc_nb_max_chrg_day, 
		0 as plc_cost_kwh, 
		0 as plc_top_default
From csi_charging_site csi
		Inner Join owr_owner owr On owr.owr_id = csi.owr_id
where owr_name='José';

INSERT INTO chp_charging_point(chp_id, stc_id, chp_code, chp_plug_type, chp_max_power_kwh, chp_top_available, chp_country_prefix, chp_nbcharsID, chp_language)
Select '+33749906278' as chp_id, stc.stc_id, 'BORNE FREE' as chp_code, 
		'T2' As chp_plug_type, 
		22 As chp_max_power_kwh, 
		1 As chp_top_available,
		'+33' As chp_country_prefix, 
		12 As chp_nbcharsId, 
		'FR' as chp_language
From stc_charging_station stc
		Inner Join csi_charging_site csi On csi.csi_id = stc.csi_id
		Inner Join owr_owner owr On owr.owr_id = csi.owr_id
where owr_name='José'
UNION ALL
Select '+33606435779' as chp_id, stc.stc_id as stc_id, 'BORNE REGLO' as chp_code, 
		'T2' As chp_plug_type, 
		22 As chp_max_power_kwh, 
		1 As chp_top_available,
		'+33' As chp_country_prefix, 
		12 As chp_nbcharsId, 
		'FR' as chp_language
From stc_charging_station stc
		Inner Join csi_charging_site csi On csi.csi_id = stc.csi_id
		Inner Join owr_owner owr On owr.owr_id = csi.owr_id
where owr_name='José';

Insert Into chg_charges(chp_id, cli_id, chg_start_date, chg_top_reservation)
Select 	(Select chp_id From chp_charging_point Where chp_id='+33606435779') As chp_id,
		(Select cli_id From cli_client Where cli_name='José') As cli_id,
		'2022-07-17 19:00:00'::timestamp As chg_start_date,
		1 As chg_top_reservation
Union All 
Select 	(Select chp_id From chp_charging_point Where chp_id='+33606435779') As chp_id,
		(Select cli_id From cli_client Where cli_name='José') As cli_id,
		'2022-07-20 15:00:00'::timestamp As chg_start_date,
		1 As chg_top_reservation;

/*
Insert Into chg_charges(chp_id, cli_id, chg_start_date, chg_end_date, chg_top_reservation)
Select 	(Select chp_id From chp_charging_point Where chp_id='+33606435779') As chp_id,
		(Select cli_id From cli_client Where cli_name='José') As cli_id,
		'2022-07-17 18:00:00'::timestamp As chg_start_date,
		'2022-07-17 18:30:00'::timestamp As chg_end_date,
		0 As chg_top_reservation;

Insert Into prv_priviledges (plc_id, cli_id, prv_id_priviledge)
Select 	(Select plc_id from plc_policies where plc_label='Politique PRIVILEGE JDO') as plc_id,
		(Select cli_id From cli_client Where cli_name='José') As cli_id,
		'12365487921' As prv_id_priviledge;
*/
