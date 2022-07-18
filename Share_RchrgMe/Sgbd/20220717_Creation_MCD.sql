-- CREATION OF RCHRG.ME MODEL
-- CREATION OF RCHRG.ME MODEL

-- Owners
DROP TABLE IF EXISTS owr_owner;

CREATE TABLE IF NOT EXISTS owr_owner
(
    owr_id serial NOT NULL,
    owr_name character varying NOT NULL,
    CONSTRAINT "PK_OWR" PRIMARY KEY (owr_id)
);

ALTER TABLE IF EXISTS owr_owner
    OWNER to "DB_ADMIN";
	

-- Reference table
DROP TABLE IF EXISTS ref_reference;

CREATE TABLE IF NOT EXISTS ref_reference
(
    ref_type character varying NOT NULL,
    ref_code character varying NOT NULL,
    ref_label character varying  NOT NULL,
    CONSTRAINT ref_reference_pkey PRIMARY KEY (ref_code, ref_type)
);

ALTER TABLE IF EXISTS ref_reference
    OWNER to "DB_ADMIN";
	
-- Application messages
DROP TABLE IF EXISTS msg_app_messages;

CREATE TABLE IF NOT EXISTS msg_app_messages
(
    msg_code character varying NOT NULL,
    msg_language character varying NOT NULL,
    msg_label character varying NOT NULL,
    CONSTRAINT "PK_MSG" PRIMARY KEY (msg_language, msg_code)
);

ALTER TABLE IF EXISTS msg_app_messages
    OWNER to "DB_ADMIN";


-- Clients
DROP TABLE IF EXISTS cli_client;

CREATE TABLE IF NOT EXISTS cli_client
(
    cli_id serial NOT NULL,
    cli_name character varying NOT NULL,
    cli_id_vehicle character varying NOT NULL,
    cli_vehicle_model character varying,
    cli_bat_capacity_wh integer NOT NULL,
    cli_nominal_range_km smallint NOT NULL,
    CONSTRAINT "PK_CLI" PRIMARY KEY (cli_id)
);

ALTER TABLE IF EXISTS cli_client
    OWNER to "DB_ADMIN";
	
-- Charging sites
DROP TABLE IF EXISTS csi_charging_site;

CREATE TABLE IF NOT EXISTS csi_charging_site
(
    csi_id serial NOT NULL,
    owr_id integer NOT NULL,
    csi_description character varying NOT NULL,
    CONSTRAINT "PK_CSI" PRIMARY KEY (csi_id),
    CONSTRAINT "FK_OWR" FOREIGN KEY (owr_id)
        REFERENCES owr_owner (owr_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS csi_charging_site
    OWNER to "DB_ADMIN";
	
-- Charging Stations
DROP TABLE IF EXISTS stc_charging_station;

CREATE TABLE IF NOT EXISTS stc_charging_station
(
    stc_id serial NOT NULL,
    csi_id integer NOT NULL,
    stc_location character varying,
    stc_max_pwr_kwh smallint,
    CONSTRAINT "PK_STC" PRIMARY KEY (stc_id),
    CONSTRAINT "FK_CSI" FOREIGN KEY (csi_id)
        REFERENCES csi_charging_site (csi_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

ALTER TABLE IF EXISTS stc_charging_station
    OWNER to "DB_ADMIN";
	
	
-- Charging points
DROP TABLE IF EXISTS chp_charging_point;

CREATE TABLE IF NOT EXISTS chp_charging_point
(
    chp_id character varying NOT NULL,
    stc_id integer NOT NULL,
    chp_code character varying,
    chp_plug_type character varying,
    chp_max_power_kwh smallint,
    chp_top_available smallint NOT NULL DEFAULT 0,
    chp_country_prefix character varying,
    chp_nbcharsId smallint NOT NULL,
    chp_language character(2),
    CONSTRAINT "PK_CHP" PRIMARY KEY (chp_id),
    CONSTRAINT "FK_STC" FOREIGN KEY (stc_id)
        REFERENCES stc_charging_station (stc_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

ALTER TABLE IF EXISTS chp_charging_point
    OWNER to "DB_ADMIN";
	

-- Charges
DROP TABLE IF EXISTS chg_charges;

CREATE TABLE IF NOT EXISTS chg_charges
(
    chg_id serial NOT NULL,
	chp_id character varying NOT NULL,
    cli_id integer NOT NULL,
    chg_start_date timestamp without time zone NOT NULL,
    chg_end_date timestamp without time zone,
    chg_provided_energy_wh integer,
    chg_top_reservation smallint NOT NULL DEFAULT 0,
    CONSTRAINT "PK_CHG" PRIMARY KEY (chg_id),
    CONSTRAINT "UK_CHG" UNIQUE (chp_id, cli_id, chg_start_date),
    CONSTRAINT "FK_CHP" FOREIGN KEY (chp_id)
        REFERENCES chp_charging_point (chp_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "FK_CLI" FOREIGN KEY (cli_id)
        REFERENCES cli_client (cli_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

ALTER TABLE IF EXISTS chg_charges
    OWNER to "DB_ADMIN";
	
-- Charges history
DROP TABLE IF EXISTS chl_charge_history;

CREATE TABLE IF NOT EXISTS chl_charge_history
(
    chg_id integer NOT NULL,
    chl_date_time timestamp without time zone NOT NULL,
    chl_energy_wh integer NOT NULL,
    CONSTRAINT "PK_CHL" PRIMARY KEY (chg_id, chl_date_time),
    CONSTRAINT "FK_CHG" FOREIGN KEY (chg_id)
        REFERENCES chg_charges (chg_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS chl_charge_history
    OWNER to "DB_ADMIN";
	
-- Charges policies
DROP TABLE IF EXISTS plc_policies;

CREATE TABLE IF NOT EXISTS plc_policies
(
    plc_id serial NOT NULL,
    csi_id integer NOT NULL,
    plc_label character varying NOT NULL,
    plc_start_date date NOT NULL,
    plc_end_date date,
    plc_free_duration_mn smallint NOT NULL,
    plc_max_duration_mn smallint,
    plc_nb_max_chrg_day smallint NOT NULL DEFAULT 1,
    plc_cost_kwh smallint NOT NULL DEFAULT 0,
    plc_top_default smallint NOT NULL DEFAULT 0,
    CONSTRAINT "PK_PLC" PRIMARY KEY (plc_id),
    CONSTRAINT "FK_CSI" FOREIGN KEY (csi_id)
        REFERENCES csi_charging_site (csi_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

ALTER TABLE IF EXISTS plc_policies
    OWNER to "DB_ADMIN";


-- Policies for priviledge clients
DROP TABLE IF EXISTS prv_priviledges;

CREATE TABLE IF NOT EXISTS prv_priviledges
(
    plc_id integer NOT NULL,
    cli_id integer NOT NULL,
    prv_id_priviledge character varying NOT NULL,
    CONSTRAINT "PK_PRV" PRIMARY KEY (prv_id_priviledge),
    CONSTRAINT "FK_CLI" FOREIGN KEY (cli_id)
        REFERENCES cli_client (cli_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "FK_PLC" FOREIGN KEY (plc_id)
        REFERENCES plc_policies (plc_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

ALTER TABLE IF EXISTS prv_priviledges
    OWNER to "DB_ADMIN";

-- Logs for Charging Stations
DROP TABLE IF EXISTS log_logs;

CREATE TABLE IF NOT EXISTS log_logs
(
    log_id serial NOT NULL,
    stc_id integer NOT NULL,
    log_date timestamp without time zone NOT NULL,
    log_msg text NOT NULL,
    CONSTRAINT "PK_LOG" PRIMARY KEY (log_id),
    CONSTRAINT "FK_STC" FOREIGN KEY (stc_id)
        REFERENCES stc_charging_station (stc_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS log_logs
    OWNER to "DB_ADMIN";