/*
    NOTE: the data dictionary does not place the CRN field correctly.
    They are listed alphabetically there, but in the tables CRN is first,
    followed by the rest of the fields alphabetically.

Notes from PennDOT's database primer:
Information about the crash such as:
  - Where: County, Municipality, Work zone
  - When: Date, Time, Day of Week, Hour of Day, Month of Year
  - Item Counts: People, Vehicles, Unbelted, Fatal, etc.
*/

create table pa_2023.crash (
    crn integer, -- crash record number, database key field that identifies a unique crash case 
    arrival_tm text, --time police arrived at the scene (hhmm)
    automobile_count integer, -- total amount of automobiles involved
    belted_death_count integer, -- total deaths of belted occupants 
    belted_susp_serious_inj_count integer, -- total suspected serious injuries of belted occupants 
    bicycle_count integer, -- total amount of bicycles involved
    bicycle_death_count integer, -- total amount of bicyclist fatalities 
    bicycle_susp_serious_inj_count integer, -- total amount of bicyclist suspected serious injuries
    bus_count integer, -- total amount of buses involved 
    chldpas_death_count integer, -- total child passengers under the age of 8 killed in the crash 
    chldpas_susp_serious_inj_count integer, -- total child passengers under the age of 8 with suspected serious injuries 
    collision_type text references pa_2023.collision_type (code), --collision category that defines crash
    comm_veh_count integer, -- total commercial vehicles involved
    cons_zone_spd_lim text, -- speed limit for the construction zone 
    county text references pa_2023.county (code), -- county code number where crash occurred 
    crash_month text, -- month when the crash occurred
    crash_year text, -- year when the crash occurred 
    day_of_week text references pa_2023.day_of_week (code), -- day of the week code when crash occurred (see column code)
    dec_lat numeric(6, 4), -- decimal format of the latitude, latitude expressed in decimal degrees (e.g. 99.9999)
    dec_long numeric(6, 4), -- decimal format of the longitude, longitude expressed in decimal degrees (e.g. 99.9999)
    dispatch_tm text, -- time police were dispatched to the scene (hhmm) 
    district text references pa_2023.district (code), -- district number where crash occurred (based on county) (see column code) 
    driver_count_16yr integer, -- total amount of 16-year-old drivers 
    driver_count_17yr integer, -- total amount of 17-year-old drivers 
    driver_count_18yr integer, -- total amount of 18-year-old drivers 
    driver_count_19yr integer, -- total amount of 19-year old drivers 
    driver_count_20yr integer, -- total amount of 20-year-old drivers 
    driver_count_50_64yr integer, -- total amount of 50 to 64-year-old drivers 
    driver_count_65_74yr integer, -- total amount of 65 to 74-year-old drivers 
    driver_count_75plus integer, -- total amount of drivers ages 75 and up 
    est_hrs_closed text, -- estimated hours roadway was closed (hhmm) 
    fatal_count integer, -- total amount of fatalities involved 
    heavy_truck_count integer, -- total amount of heavy trucks involved 
    horse_buggy_count integer, -- total number of horse and buggy units involved in the crash 
    hour_of_day text, -- the hour of day when the crash occurred (00 to 23) TODO: add constraint
    illumination text references pa_2023.illumination (code), -- code that defines lighting at crash scene (see column code) 
    injury_count integer, -- total count of all injuries sustained
    intersect_type text references pa_2023.intersect_type (code), -- code that defines the intersection type (see column code) 
    intersection_related boolean, -- was this midblock crash related to a nearby intersection?
    lane_closed boolean, -- was there a lane closure?
    latitude text, -- gps latitude determined by penndot (dd mm:ss.ddd)
    ln_close_dir text references pa_2023.lane_closure_direction (code), -- direction of traffic in closed lane (s) (see column code) 
    location_type text references pa_2023.location_type (code), -- code that defines the crash location (see column code) 
    longitude text, -- gps longitude determined by penndot (in negative degrees) (dd mm:ss.ddd)
    max_severity_level text references pa_2023.max_severity_level (code), -- injury severity level of the crash (see column code)
    mcycle_death_count integer, -- total amount of motorcyclist fatalities 
    mcycle_susp_serious_inj_count integer, -- total amount of motorcyclist suspected serious injuries 
    motorcycle_count integer, -- total amount of motorcycles involved 
    municipality text references pa_2023.municipalities (code), -- municipality code, see municipality code 
    nonmotr_count integer, -- total number of non-motorists involved in the crash 
    nonmotr_death_count integer, -- total number of non-motorists killed in the crash 
    nonmotr_susp_serious_inj_count integer, -- total number of non-motorists with suspected serious injures in the crash 
    ntfy_hiwy_maint boolean, -- penndot highway maintenance notified? 
    ped_count integer, -- total pedestrians involved
    ped_death_count integer, -- total pedestrian fatalities 
    ped_susp_serious_inj_count integer, -- total pedestrians with an injury severity of “suspected serious injury” 
    person_count integer, -- total people involved 
    police_agcy text references pa_2023.police_agencies (code), -- code of the reporting police agency (see police agency code)
    possible_inj_count integer, -- total number of people with an injury severity of “possible injury” 
    rdwy_surf_type_cd text references pa_2023.rdwy_surface_type (code), -- code for the roadway surface type –only for fatal crashes (see column code) 
    relation_to_road text references pa_2023.relation_to_road (code), -- code for the crash’s relativity to the road (see column code) 
    road_condition text references pa_2023.road_condition (code), -- roadway surface condition code (see column code) 
    roadway_cleared text, -- time the roadway was opened to traffic (0000-2359 or 9999) TODO: add constraint
    sch_bus_ind boolean, -- did the crash involve a school bus?
    sch_zone_ind boolean, -- did the crash occur in a school zone?
    secondary_crash boolean, -- was this crash caused at least in part to a prior crash?
    small_truck_count integer, -- total amount of small trucks involved 
    spec_juris_cd text references pa_2023.spec_juris_cd (code), -- code that defines any special jurisdiction – only for fatal crashes (see column code) 
    susp_minor_inj_count integer, -- total number of people with an injury severity of suspected minor injury 
    susp_serious_inj_count integer, -- total number of people with an injury severity of suspected serious injury 
    suv_count integer, -- total count of sport utility vehicles involved 
    tcd_func_cd text references pa_2023.tcd_func_cd (code), -- code for traffic control device state (see column code) 
    tcd_type text references pa_2023.tcd_type (code), -- code that defines the traffic control device (see column code) 
    tfc_detour_ind boolean, -- was traffic detoured?
    time_of_day text, -- the time of day when the crash occurred (0000 through 2359)
    tot_inj_count integer, -- count of total injuries sustained by persons involved in this crash. does not include fatal injuries. 
    total_units integer, -- total count of all vehicles and pedestrians
    unb_death_count integer, -- no. of people killed not wearing a seatbelt
    unb_susp_serious_inj_count integer, -- total # of unbelted sustaining suspected serious injuries
    unbelted_occ_count integer, -- total count of all unbelted occupants 
    unk_inj_deg_count integer, -- no. of injuries with unknown severity 
    unk_inj_per_count integer, -- no. of people that are unknown if injured 
    urban_rural text, -- code to classify crash as urban or rural (1=rural, 2=urbanized, 3=urban) 
    van_count integer, -- total amount of vans involved 
    vehicle_count integer, -- total number of all motor vehicles involved in the crash 
    weather1 text references pa_2023.weather1 (code), -- code for the first weather condition at time of crash (see column code)
    weather2 text references pa_2023.weather2 (code), -- code for the second weather condition at time of crash (see column code) 
    work_zone_ind boolean, -- did the crash occur in a work zone
    work_zone_loc text references pa_2023.work_zone_loc (code), -- the work zone location code (see column code)
    work_zone_type text references pa_2023.work_zone_type (code), -- code to define the type of work zone (see column code)
    workers_pres boolean, -- were construction personnel present?
    wz_close_detour boolean, -- was traffic rerouted due to work zone?
    wz_flagger boolean, -- did work zone have a flagman? 
    wz_law_offcr_ind boolean, -- did work zone have a patrolman?
    wz_ln_closure boolean, -- did work zone have a lane closure?
    wz_moving boolean, -- was there moving work in the zone?
    wz_other boolean, -- was this a special type of work zone?
    wz_shlder_mdn boolean, -- was a median/shoulder in the zone?
    wz_workers_inj_killed boolean -- were any work zone workers injured or killed as a result of this crash?
);

/*
Notes from PennDOT's database primer:
Information about commercial vehicles, such as carrier information, the cargo body type, Hazmat
information, and official agency registration numbers.
*/
create table pa_2023.commveh (
    crn integer,  -- crash record number, database key field that identifies a unique crash case 
    axle_cnt text,  -- number of axles on the vehicle
    cargo_bd_type text references pa_2023.cargo_bd_type (code),  -- code for the cargo carrier’s body type (see column code)
    carrier_addr1 text,  -- address of carrier 
    carrier_addr2 text,  -- address of carrier line
    carrier_city text,  -- city of carrier
    carrier_nm text,  -- name of the carrier
    carrier_state text,  -- state of carrier
    carrier_zip text,  -- zip code of carrier
    carrier_tel text,  -- telephone of carrier
    gvwr text,  -- gross vehicle weight rating 
    hazmat_cd1 text references pa_2023.hazmat_code (code),  -- hazmat code for material one onboard (see column code)
    hazmat_cd2 text references pa_2023.hazmat_code (code),  -- hazmat code for material two onboard (see column code)
    hazmat_cd3 text references pa_2023.hazmat_code (code),  -- hazmat code for material three onboard (see column code)
    hazmat_cd4 text references pa_2023.hazmat_code (code),  -- hazmat code for material four onboard (see column code)
    hazmat_ind boolean,  -- indicator for hazmat on board
    hazmat_rel_ind1 boolean,  -- indicator for hazmat one released
    hazmat_rel_ind2 boolean,  -- indicator for hazmat two released
    hazmat_rel_ind3 boolean,  -- indicator for hazmat three released
    hazmat_rel_ind4 boolean,  -- indicator for hazmat four released
    icc_num text,  -- interstate commercial carrier number (not in use after 12/31/15) 
    osize_load_ind boolean,  -- oversize load indicator
    partial_trailer_vin text,  -- first 11 characters of the trailer vin
    permitted integer, -- (01 = non-permitted load, 02 = permitted load, 99 = unknown)
    puc_num text,  -- pa utility commission number
    special_sizing1 text,  -- does this commercial unit have special sizing restrictions (00=No special sizing, 01=over height, 02=over length, 03=over weight, 04=over width)
    special_sizing2 text,  -- second special sizing restriction 
    special_sizing3 text,  -- third special sizing restriction 
    special_sizing4 text,  -- fourth special sizing restriction 
    type_of_carrier text references pa_2023.type_of_carrier (code),  -- type of commercial carrier (see column code)
    unit_num integer,  -- unit number of the vehicle in the crash event 
    usdot_num text,  -- us dept of transportation number 
    veh_config_cd text references pa_2023.veh_config_cd (code)  -- vehicle configuration code (see column code)
);

/*
Notes from PennDOT's database primer:
Information that pertains to motorcycle/pedal cycles, such as helmet usage and appropriate attire
and other accessories such as side bags
*/
create table pa_2023.cycle (
    crn integer, -- crash record number, database key field that identifies a unique crash case 
    mc_engine_size text, -- motorcycle engine size (cc)
    mc_passngr_ind boolean, -- did the motorcycle have a passenger?
    mc_bag_ind boolean, -- did the motorcycle have side bags?
    mc_trail_ind boolean, -- did the motorcycle have trailer?
    mc_dvr_edc_ind boolean, -- did motorcycle driver have safety training?
    mc_dvr_eyeprt_ind boolean, -- did motorcycle driver wear eye protection?
    mc_dvr_lngslv_ind boolean, -- did motorcycle driver have long sleeves?
    mc_dvr_lngpnts_ind boolean, -- did motorcycle driver wear long pants?
    mc_dvr_boots_ind boolean, -- did motorcycle driver wear boots?
    mc_dvr_hlmton_ind boolean, -- did motorcycle driver wear helmet?
    mc_dvr_hlmtdot_ind boolean, -- was driver’s helmet penndot certified?
    mc_dvr_hlmt_type text references pa_2023.helmet_type (code), -- code for helmet type of the motorcycle driver (see column code)
    mc_pas_eyeprt_ind boolean, -- did motorcycle passenger wear eye protection?
    mc_pas_lngslv_ind boolean, -- did motorcycle passenger have long sleeves?
    mc_pas_lngpnts_ind boolean, -- did motorcycle passenger wear long pants?
    mc_pas_boots_ind boolean, -- did motorcycle passenger wear boots?
    mc_pas_hlmton_ind boolean, -- did motorcycle passenger wear a helmet?
    mc_pas_hlmtdot_ind boolean, -- was passenger’s helmet penndot cert.?
    mc_pas_hlmt_type text references pa_2023.helmet_type (code), -- code for helmet type of the motorcycle pass. (see column code)
    unit_num integer -- unit number of the vehicle in the crash event
);

/*
Notes from PennDOT's database primer:
Series of Yes/No items that help refine lookups for specific factors about the crash such as:
Drinking Driver, Use of a Cell Phone, Fatal Crash, Motorcycle involved, and over 60 other crash
defining items.
*/
create table pa_2023.flag (
    crn integer, -- crash record number – identifies a unique crash, database key field that identifies a unique crash case 
    aggressive_driving boolean, -- at least one aggressive driver action
    alcohol_related boolean, -- at least one driver or pedestrian with reported or suspected alcohol use
    angle_crash boolean, -- first harmful event involved a vehicle striking another at an angle
    atv boolean, -- crash involved at least one all-terrain- vehicle (atv).
    backup_prior boolean, -- indicates that traffic was backed up due to a prior crash
    backup_nonrecurring boolean, -- indicates that traffic was backed up due to a nonrecurring special event
    backup_congestion boolean, -- indicates that traffic was backed up due to normal congestion
    bicycle boolean, -- a bicycle was involved
    cell_phone boolean, -- driver using cell phone (hand held or hands free)
    child_passenger boolean, -- the crash involved at least one vehicle passenger under the age of 12.
    comm_vehicle boolean, -- crash has at least one involved commercial vehicle
    core_network boolean, -- crash took place on a core network roadway.
    cross_median boolean, -- at least one unit crossed a median
    curve_dvr_error boolean, -- at least one driver action involving curve negotiation
    curved_road boolean, -- curve in road
    deer_related boolean, -- deer struck or deer in roadway
    distracted boolean, -- at least one driver action indicating a distraction
    drinking_driver boolean, -- at least one drinking driver
    driver_16yr boolean, -- at least one driver 16 years of age
    driver_17yr boolean, -- at least one driver 17 years of age
    driver_18yr boolean, -- at least one driver 18 years of age
    driver_19yr boolean, -- at least one driver 19 years of age
    driver_20yr boolean, -- at least one driver 20 years of age
    driver_50_64yr boolean, -- at least one driver 50-64 years of age
    driver_65_74yr boolean, -- at least one driver 65-74 years of age
    driver_75plus boolean, -- at least one driver 75 plus years of age
    drug_related boolean, -- indicates either a motor vehicle driver or non-motorist (such as a bicyclist or pedestrian) had a condition of drug use or was suspected of drug use by police or had a positive drug test result indicating presence of a controlled substance. (definition changed may 2022)
    drugged_driver boolean, -- indicates any motor vehicle driver had a condition of drug use or was suspected of drug use by police or had a positive drug test result indicating presence of a controlled substance. (definition changed may 2022)
    fatal boolean, -- at least one fatality
    fatal_or_susp_serious_inj boolean, -- the crash has at least one person who was killed or sustained a suspected serious injury
    fatigue_asleep boolean, -- at least one driver with a condition listed fatigued or asleep
    fire_in_vehicle boolean, -- at least one vehicle with fire damage
    hazardous_truck boolean, -- at least one heavy truck carrying hazardous material
    hit_barrier boolean, -- at least one unit hit a barrier
    hit_bridge boolean, -- at least one unit hit a bridge
    hit_deer boolean, -- at least one unit hit a deer
    hit_embankment boolean, -- at least one unit hit an embankment
    hit_fixed_object boolean, -- crash description of hit fixed object
    hit_gdrail boolean, -- at least one unit hit a guide rail
    hit_gdrail_end boolean, -- at least one unit hit a guide rail end
    hit_parked_vehicle boolean, -- at least one legally or illegally parked vehicle was struck
    hit_pole boolean, -- at least one unit hit a pole
    hit_tree_shrub boolean, -- at least one unit hit a tree or shrub
    hit_utility_pole boolean, -- at least one unit hit a utility pole (NOTE: this was a second "hit tree_shrub" in the data dictionary; assumed it should be "hit_utiltity_pole")
    ho_oppdir_sdswp boolean, -- crash description of head-on or opposite direction sideswipe
    horse_buggy boolean, -- at least one horse and buggy unit involved
    hvy_truck_related boolean, -- at least one heavy truck was involved
    icy_road boolean, -- icy road indicator
    illegal_drug_related boolean, -- at least one driver or pedestrian had reported or suspected illegal drug use
    illumination_dark boolean, -- illumination indicates that the crash scene lighting was dark
    impaired_driver boolean, -- at least one driver was impaired by drugs or alcohol at least one person was injured in the crash
    injury boolean, -- at least one person was injured in the crash, 0=no, 1=yes
    injury_or_fatal boolean, -- at least one person was injured or killed in the crash
    intersection boolean, -- crash took place at an intersection
    interstate boolean, -- crash took place on a non-turnpike interstate
    lane_departure boolean, -- the crash had an indication that at least one vehicle departed their lane of travel during the crash events
    left_turn boolean, -- the crash had at least 1 unit that performed a left turn movement.
    limit_65mph boolean, -- the crash took place on a roadway that had a posted speed limit of 65 miles per hour
    limit_70mph boolean, -- the crash took place on a roadway that had a posted speed limit of 70 miles per hour
    local_road boolean, -- the crash involved at least one local road
    local_road_only boolean, -- the crash involved only local roadway
    marijuana_drugged_driver boolean, -- the crash involved at least 1 driver who tested positive for the presence of marijuana
    marijuana_related boolean, -- the crash involved at least 1 driver, pedestrian, or other non-motorist who tested positive for the presence of marijuana
    mature_driver boolean, -- the crash involved at least 1 driver over the age of 65
    mc_drinking_driver boolean, -- at least one motorcycle driver has reported or suspected alcohol use
    motorcycle boolean, -- the crash involved at least one motorcycle
    multiple_vehicle boolean, -- crash involved at least 2 vehicles
    nhtsa_agg_driving boolean, -- the crash meets the nhtsa definition of aggressive driving
    no_clearance boolean, -- at least one unit proceeded without clearance after a stop.
    non_intersection boolean, -- the crash did not take place at an intersection
    opioid_related boolean, -- at least one driver or non-motorist was suspected of drug use and tested positive for opioids
    other_freeway boolean, -- indicates that the crash took place on a non-turnpike/non-interstate freeway
    overturned boolean, -- the crash involved at least one overturned vehicle
    pedestrian boolean, -- the crash involved at least one pedestrian, or pedestrian converyance
    phantom_vehicle boolean, -- the crash involved at least one unit that contributed to the crash but did not have any harmful events.
    possible_injury boolean, -- the crash has at least one person who sustained a possible injury
    property_damage_only boolean, -- the crash did not have any injuries or fatalities
    psp_reported boolean, -- crash investigated by the pennsylvania state police
    ramp boolean, -- the crash involved an interchange ramp
    ramp_segment boolean, -- the crash took place on an interchange ramp, between the ramp begin and the ramp end
    ramp_terminal boolean, -- the crash took place where an interchange ramp from a limited access highway meets a non-limited access roadway
    rear_end boolean, -- crash description of rear end
    roundabout boolean, -- the crash took place at a modern roundabout intersection.
    running_red_lt boolean, -- at least one driver ran a red light
    running_stop_sign boolean, -- at least one driver ran a stop sign
    rural boolean, -- crash took place in a rural municipality
    school_bus boolean, -- the crash involved at least one school bus
    school_bus_related boolean, -- the crash involved at least one school bus unit with or without a harmful event
    school_bus_unit boolean, -- the crash involved at least one school bus unit with a harmful event
    school_zone boolean, -- the crash took place in a school zone
    shldr_related boolean, -- shoulder related indicator
    signalized_int boolean, -- the crash took place at a signalized intersection 
    single_vehicle boolean, -- the crash involved a single vehicle
    snow_slush_road boolean, -- the crash involved a snow or slush covered road
    snowmobile boolean, -- crash involved at least one snowmobile unit
    speed_change_lane boolean, -- the crash occurred where an acceleration or deceleration lane was present on a limited access highway
    speeding boolean, -- at least one vehicle was speeding
    speeding_related boolean, -- at least one vehicle was speeding, racing or was driving too fast for conditions
    state_road boolean, -- the crash involved at least one state owned road
    stop_controlled_int boolean, -- the crash took place at a stop controlled intersection
    sudden_deer boolean, -- the crash involved a deer in the roadway
    suspected_minor_injury boolean, -- the crash has at least one person who sustained a suspected minor injury
    suspected_serious_injury boolean, -- the crash has at least one person who sustained a suspected serious injury
    sv_run_off_rd boolean, -- single vehicle run off road
    tailgating boolean, -- at least one driver was tailgating or following too closely
    train boolean, -- the crash involved a train
    train_trolley boolean, -- the crash involved a train or trolley
    trolley boolean, -- the crash involved a trolley
    turnpike boolean, -- the crash took place on the turnpike or a turnpike spur
    unbelted boolean, -- anyone in crash unbelted? (applicable vehicles only)
    underage_drnk_drv boolean, -- the crash involved at least one under age drinking driver
    unlicensed boolean, -- the crash involved at least one unlicensed driver
    unsignalized_int boolean, -- the crash took place at an unsignalized intersection
    urban boolean, -- the crash took place in an urban municipality
    vehicle_failure boolean, -- the crash involved at least one vehicle failure that contributed to the crash
    vehicle_towed boolean, -- at least one vehicle was towed from the scene
    vulnerable_roadway_user boolean, -- the crash involved at least 1 vulnerable roadway user (pedestrian, pedestrian conveyance, bicyclist)
    vulnerable_roadway_user_fatal boolean, -- the crash involved at least 1 fatality to a vulnerable roadway user
    wet_road boolean, -- wet road indicator
    work_zone boolean, -- work zone indicator
    young_driver boolean -- the crash involved at least 1 driver age 16-20
);

/*
Notes from PennDOT's database primer:
Information about all people from all units related to the crash such as: Age, Sex, Drug and
alcohol results, Where they sat and in which vehicle, Were they ejected from the vehicle? etc.
*/
create table pa_2023.person (
    crn integer, -- crash record number, database key field that identifies a unique crash case 
    age integer, -- age of person (those under the age of 1 are listed as 1, those over the age of 98 are listed as 98 and 99 indicates an unknown age)
    airbag_pads text, -- airbag deployment for motor vehicle occupant or bicycle/motorcycle protective gear (see column code) 
    airbag1 text references pa_2023.airbag (code), -- airbag(s) that were deployed for this person (see column code) 
    airbag2 text references pa_2023.airbag (code), -- airbag(s) that were deployed for this person (see column code) 
    airbag3 text references pa_2023.airbag (code), -- airbag(s) that were deployed for this person (see column code) 
    airbag4 text references pa_2023.airbag (code), -- airbag(s) that were deployed for this person (see column code) 
    dvr_lic_state text references pa_2023.state_code (code), -- state of licensed driver (see column code) 
    dvr_ped_condition text references pa_2023.dvr_ped_condition (code), -- driver pedestrian condition code (see column code) 
    ejection_ind text references pa_2023.ejection_ind (code), -- ejection indicator – only for vehicle occupants (see column code) 
    eject_path_cd text references pa_2023.eject_path_cd (code), -- ejection path code– only for vehicle occupants (see column code) 
    extric_ind text references pa_2023.extric_ind (code), -- extrication indicator– only for vehicle occupants (see column code) 
    inj_severity text references pa_2023.inj_severity (code), -- injury severity code (see column code) 
    non_motorist boolean, -- indicates if this person is a non-motorist
    person_num integer, -- person number – sequential per unit 
    person_type text references pa_2023.person_type (code), -- person type code (see column code) 
    restraint_helmet text references pa_2023.helmet_type (code), -- restraint or helmet (see column code) 
    seat_position text references pa_2023.seat_position (code), -- seat in unit where person sat (see column code) 
    sex text references pa_2023.sex (code), -- sex of this individual; (see column code) 
    transported boolean, -- transported to medical facility y/n
    transported_by text, -- method by which the person was transported (00 = not transported, 01 = ems air, 02 = ems ground, 98 = other, 99 = unknown)
    unit_num integer, -- unit number of the vehicle (or pedestrian) assigned to this person 
    vulnerable_roadway_user boolean -- is this person classified as a vulnerable roadway user?
);

/*
Notes from PennDOT's database primer:
Information about all the roadways involved in the crash such as: Route number or name, Segment, Offset, Type of Roadway, Rating, and many other Roadway defining elements.
*/
create table pa_2023.roadway (
    crn integer, -- crash record number, database key field that identifies a unique crash case 
    access_ctrl text references pa_2023.access_ctrl (code), -- access control code– only for state roads (see column code) 
    adj_rdwy_seq integer, -- adjusted roadway sequence number 
    lane_count text, -- travel lane count (both directions for non- divided roads. single direction for divided highways) 
    offset_in_segment text, -- offset (in feet) within the segment – only for state roads 
    rdwy_county text references pa_2023.county (code), -- roadway county code (could differ from county of crash) (see column code) for county 
    rdwy_orient text references pa_2023.rdwy_orient (code), -- roadway orientation code (see column code) 
    rdwy_seq_num integer, -- crash roadway sequence number 
    road_owner text references pa_2023.road_owner (code), -- roadway maintained by state, local or private jurisdiction. (see column code) 
    route text, -- route number – only for state roads 
    segment text, -- segment number– only for state roads 
    speed_limit integer, -- speed limit 
    street_name text -- name of the roadway 
);

/*
Notes from PennDOT's database primer:
Information about the types and kind of trailers that were being towed by vehicles.
*/
create table pa_2023.trailveh (
    crn integer,  -- crash record number, database key field that identifies a unique crash case 
    trl_seq_num integer,  -- trailer sequence number 
    trailer_partial_vin text,  -- first 12 characters of the vin for this trailer 
    trl_veh_reg_state text references pa_2023.state_code (code),  -- trailer registration state (see state codes)
    trl_veh_tag_num text,  -- trailer registration tag number 
    trl_veh_tag_yr text,  -- trailer registration year 
    trl_veh_type_cd text references pa_2023.trl_veh_type_cd (code),  -- trailer type code (see column code) 
    unit_num integer  -- unit number of the vehicle the trailer is associated with 
);

/*
Notes from PennDOT's database primer:
Information about all vehicles involved in the crash such as: Body Type, Commercial Vehicle,
Movement, Position, Unit number in the crash and other vehicle related information.

NOTE: non-motorist units are also kept in this table.
*/
create table pa_2023.vehicle (
    crn integer,  -- crash record number, database key field that identifies a unique crash case 
    avoid_man_cd text references pa_2023.avoid_man_cd (code),  -- avoidance maneuver code - only for fatal crashes (see column code) 
    body_type text references pa_2023.body_type (code),  -- body type code (see column code) 
    comm_veh boolean,  -- commercial vehicle indicator (n=no u=unknown y=yes)
    damage_ind text references pa_2023.damage_ind (code),  -- damage indicator (see column code) 
    dvr_pres_ind text references pa_2023.dvr_pres_ind (code),  -- driver presence indicator (see column code) 
    emerg_veh_use_cd text references pa_2023.emerg_veh_use_cd (code),  -- special vehicle use code– only for fatal crashes (see column code) 
    grade text references pa_2023.grade (code),  -- grade code (see column code) 
    -- hazmat_ind boolean,  -- indicates if this unit was carrying hazardous material
    impact_point text references pa_2023.impact_point (code),  -- initial impact point (see column code) 
    ins_ind boolean,  -- insurance indicator
    make_cd text references pa_2023.veh_make (code),  -- make code (see vehicle make table)
    model_yr text,  -- model year of the vehicle 
    nm_at_intersection text, -- non-motorist at intersection? (y=yes, n=no, u=unknown)
    nm_crossing_tcd text references pa_2023.non_motorist_crossing_tcd (code), -- non-motorist crossing traffic control device (see column code) 
    nm_distraction text references pa_2023.non_motorist_distraction (code), -- non-motorist distraction (see column code) 
    nm_in_crosswalk text references pa_2023.non_motorist_in_crosswalk (code), -- non-motorist in crosswalk? (see column code) 
    nm_lighting text, -- non-motorist lighting (y=yes, n=no, u=unknown)
    nm_powered text references pa_2023.non_motorist_powered_conveyance (code), -- non-motorist powered conveyance? (see column code) 
    nm_reflect text, -- non-motorist reflectors or reflective wear? (y=yes, n=no, u=unknown)
    owner_driver text references pa_2023.owner_driver (code),  -- was the vehicle owned by the driver? if not, who owns the vehicle? (see column code) 
    partial_vin text,  -- vehicle identification number (first eleven characters) 
    people_in_unit integer,  -- total people in unit
    prin_imp_pt text references pa_2023.impact_point (code),  -- principle impact point – only for fatal crashes (see column code for impact point) 
    rdwy_alignment text references pa_2023.rdwy_alignment (code),  -- roadway alignment code (see column code) 
    special_usage text references pa_2023.special_usage (code),  -- special usage of the vehicle (see column code)
    tow_ind boolean, -- NOTE: not in data dictionary but is in CSVs
    travel_direction text references pa_2023.travel_direction (code),  -- travel direction of the vehicle (see column code) 
    travel_spd text,  -- estimated travel speed 
    trl_veh_cnt text,  -- trailing vehicle count 
    under_ride_ind text references pa_2023.under_ride_ind (code),  -- under ride damage indicator– only for fatal crashes (see column code) 
    unit_num integer,  -- unit number assigned to the vehicle or pedestrian 
    unit_type text references pa_2023.unit_type (code),  -- unit type (see column code) 
    veh_color_cd text references pa_2023.veh_color_cd (code),  -- vehicle color code (see column code) 
    veh_movement text references pa_2023.veh_or_non_motorist_movement (code),  -- vehicle or non-motorist movement code (see column code) 
    veh_position text references pa_2023.veh_or_non_motorist_position (code),  -- vehicle or non-motorist position code (see column code) 
    veh_reg_state text references pa_2023.state_code (code),  -- vehicle registration state (see state codes)
    veh_role text references pa_2023.veh_role (code),  -- vehicle role (see column code) 
    veh_type text references pa_2023.veh_or_non_motorist_type (code),  -- vehicle or non-motorist type (see column code) 
    vina_body_type_cd text references pa_2023.vina_body_type_cd (code)  -- body type code interpreted by vina software (see column code) 
);
