-- Enregistrement
-- Enregistrement

Select plc.plc_free_duration_mn as Free_Duration_mn,
		plc.plc_max_duration_mn as Max_Duration_mn,
		plc.plc_nb_max_chrg_day as Nb_Max_Chrg_Day
From chp_charging_point chp
		Inner Join stc_charging_station stc On stc.stc_id = chp.stc_id
		Inner Join plc_policies plc On plc.csi_id = stc.csi_id
Where plc.plc_top_default=1
And chp.chp_id = "ID passé en paramètre"

-- Textes pour les messages
Select msg_code as Code, msg_label as Label
From msg_app_messages
Where msg_language=(Select chp_language From chp_charging_point where chp_id = "ID passé en paramètre")
--Where msg_language=(Select chp_language From chp_charging_point where chp_id = '+33606435779')

-- Mise à jour du statut vers disponible
Update chp_charging_point Set chp_top_available=1 Where chp_id = "ID passé en paramètre"

-- Mise à jour du statut vers indisponible
Update chp_charging_point Set chp_top_available=0 Where chp_id = "ID passé en paramètre"

-- Renvoi du prochain client et temps avant la prochaine charge dans les 24h
Select now(), chg_start_date, cli_id as ID_Client, floor(extract(epoch from (chg_start_date - Now()))) As Start_Into
From chg_charges
Where chg_top_reservation = 1
And chg_start_date > Now()
And DATE_PART('day', Now() - chg_start_date) <=1
And chp_id = "ID point de charge passé en paramètre"
Order by chg_start_date Asc Limit 1

-- Vérifie si le client existe
Select 1 from cli_client where cli_id = "ID passé en paramètre"

-- Vérifie si le client peut charger : la requette ci-dessous doit renvoyer au moins 1 ligne
Select chg.cli_id, plc.plc_nb_max_chrg_day, count(*) As Nb_Charges
From chg_charges chg
		Inner Join chp_charging_point chp On chp.chp_id = chg.chp_id
		Inner Join stc_charging_station stc On stc.stc_id = chp.stc_id
		Inner Join plc_policies plc On plc.csi_id = stc.csi_id
		Left Join prv_priviledges prv On prv.cli_id = chg.cli_id
Where chg.chg_top_reservation = 0
And DATE_PART('day', Now() - chg.chg_start_date) = 0
And (plc.plc_top_default = 1 Or prv.plc_id Is Not Null) 
And chg.cli_id = "ID client passé en paramètre"
And chg.chp_id = "ID borne passé en paramètre"
Group By chg.cli_id, plc.plc_nb_max_chrg_day
Having Count(*)< plc.plc_nb_max_chrg_day


--Vérifie la dispo d'autres bornes du même site et en renvoie deux
Select chp.chp_code As Code, chp.chp_id As Id_Borne
From chp_charging_point chp
		Inner Join stc_charging_station stc On stc.stc_id = chp.stc_id
		Inner Join stc_charging_station OtherStc On OtherStc.csi_id = stc.csi_id 
		Inner Join chp_charging_point chpavlb On chpavlb.stc_id = OtherStc.stc_id
Where chp.chp_id = '+33606435779'  --"ID borne passé en paramètre"
And OtherStc.stc_id <> stc.stc_id
And chpavlb.chp_top_available = 1
Limit 2

