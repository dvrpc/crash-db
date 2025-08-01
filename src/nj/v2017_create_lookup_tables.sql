create or replace procedure nj_v2017_create_and_populate_lookup_tables()
language plpgsql
as
$body$
declare
    lookup_schema text = 'nj_2017_lookup';
    table_name text;
    table_names text[] := '{airbag_deployment, alcohol_test_given, alcohol_test_type, cargo_body_type, contrib_circ, crash_type, driven_left_towed, ejection, environmental_condition, extent_of_damage, hazmat_status, light_condition, location_of_most_severe_injury, ncic, oversized_overweight_permit, physical_condition, physical_status, position_in_veh, police_dept, pre_crash_action, refused_med_attn, removed_by, road_divided_by, road_grade, road_horizontal_alignment, road_surface_condition, road_surface_type, road_system, route_suffix, safety_equipment, sequence_of_events, special_function_vehicles, unit_of_measure, temp_traffic_control_zone, traffic_controls, type_of_most_severe_injury, veh_color, veh_impact_area, veh_type, veh_use, veh_weight_rating}';
begin

    raise info 'Creating and populating % tables', lookup_schema;
    -- Create lookup tables.
    foreach table_name in ARRAY table_names LOOP
        execute format($create_query$create unlogged table if not exists %I.%I (code text not null unique, description text not null)$create_query$, lookup_schema, table_name);
    end loop;

    -- Populate lookup tables.
    begin
        -- 2017 Crash Report Manual, p. 58.
        execute format($q1$insert into %I.airbag_deployment (code, description) values
            ('00', 'Unknown'),
            ('01', 'Front'),
            ('02', 'Side'),
            ('03', 'Other (Knee, Airbelt, etc)'),
            ('04', 'Combination'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 NJTR-1 form has boxes for each of these options;
        -- data is truncated down to one letter.
        execute format($q1$insert into %I.alcohol_test_given (code, description) values
            ('Y', 'Yes'),
            ('N', 'No'),
            ('R', 'Refused')$q1$, lookup_schema);

        -- 2017 NJTR-1 form has boxes for each of these options;
        -- data is truncated down to two letters.
        execute format($q1$insert into %I.alcohol_test_type (code, description) values
            ('BL', 'Blood'),
            ('BR', 'Breath'),
            ('UR', 'Urine')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 76.
        execute format($q1$insert into %I.cargo_body_type (code, description) values
            ('00', 'Unknown'),
            ('01', 'Bus (9-15 seats)'),
            ('02', 'Bus (> 15 seats)'),
            ('03', 'Van/Enclosed Box'),
            ('04', 'Cargo Tank'),
            ('05', 'Flatbed'),
            ('06', 'Dump'),
            ('07', 'Concrete Mixer'),
            ('08', 'Auto Transporter'),
            ('09', 'Garbage/Refuse'),
            ('10', 'Hopper (grain, gravel, chips)'),
            ('11', 'Pole/Log (Trailer)'),
            ('12', 'Intermodal Chassis'),
            ('13', 'No Cargo Body'),
            ('14', 'Veh Towing Another Veh'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, pp 80-4.
        execute format($q1$ insert into %I.contrib_circ (code, description) values
            ('00', 'Unknown'),
            -- Driver/Pedalcycleist Actions (01-29)
            ('01', 'Unsafe Speed'),
            ('02', 'Driver Inattention'),
            ('03', 'Failed to Obey Traffic Signal'),
            ('04', 'Failed to Yield ROW to Vehicle/Pedes'),
            ('05', 'Improper Lane Change'),
            ('06', 'Improper Passing'),
            ('07', 'Improper Use/Failed to Use Turn Signal'),
            ('08', 'Improper Turning'),
            ('09', 'Following Too Closely'),
            ('10', 'Backing Unsafely'),
            ('11', 'Improper Use/No Lights'),
            ('12', 'Wrong Way'),
            ('13', 'Improper Parking'),
            ('14', 'Failure to Keep Right'),
            ('15', 'Failure to Remove Snow/Ice'),
            ('16', 'Failed to Obey Stop Sign'),
            ('17', 'Distracted - Hand Held Electronic Dev'),
            ('18', 'Distracted - Hands Free Electronic Dev'),
            ('19', 'Distracted by Passenger'),
            ('20', 'Other Distraction Inside Veh'),
            ('21', 'Other Distraction Outside Veh'),
            ('25', 'None'),
            ('29', 'Other Drive/Pedalcyclist Action'),
            -- Vehicle Factors (31-49)
            ('31', 'Defective Lights'),
            ('32', 'Brakes'),
            ('33', 'Steering'),
            ('34', 'Tires'),
            ('35', 'Wheels'),
            ('36', 'Windows/Windshield'),
            ('37', 'Mirrors'),
            ('38', 'Wipers'),
            ('39', 'Veh Coupling/Hitch/Safety Chains'),
            ('40', 'Separated Load/Spill'),
            ('49', 'Other Vehicle Factors'),
            -- Road/Environ Factors (51-69)
            ('51', 'Road Surface Condition'),
            ('52', 'Obstruction/Debris in Road'),
            ('53', 'Ruts, Holes, Bumps'),
            ('54', 'Control Device Defective or Missing'),
            ('55', 'Improper Work Zone'),
            ('56', 'Physical Obstructions (viewing, etc)'),
            ('57', 'Animals in Roadway'),
            ('58', 'Improper/Inadequate Lane Markings'),
            ('59', 'Sunglare'),
            ('60', 'Traffic Congestion - Prior Incident'),
            ('61', 'Traffic Congestion - Regular'),
            ('69', 'Other Roadway Factors'),
            -- Pedestrian Factors (71-89)
            ('71', 'Failed to Obey Traffic Control Device'),
            ('72', 'Crossing Where Prohibited'),
            ('73', 'Dark Clothing/Low Visibility to Driver'),
            ('74', 'Inattentive'),
            ('75', 'Failure to Yield ROW'),
            ('76', 'Walking on Wrong Side of Road'),
            ('77', 'Walking in Road when Sidewalks Present'),
            ('78', 'Running/Darting Across Traffic'),
            ('85', 'None'),
            ('89', 'Other Pedestrian Factors'),
            --
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 67.
        execute format($q1$ insert into %I.crash_type (code, description) values
            ('00', 'Unknown'),
            -- With other moving vehicle as first event
            ('01', 'Same Direction (Rear End)'),
            ('02', 'Same Direction (Side Swipe)'),
            ('03', 'Right Angle'),
            ('04', 'Opposite Direction (Head On, Angular)'),
            ('05', 'Opposite Direction (Side Swipe)'),
            ('06', 'Struck Parked Vehicle'),
            ('07', 'Left Turn/U Turn'),
            ('08', 'Backing'),
            ('09', 'Encroachment'),
            -- With below as first event
            ('10', 'Overturned'),
            ('11', 'Fixed Object'),
            ('12', 'Animal'),
            ('13', 'Pedestrian'),
            ('14', 'Pedalcyclist'),
            ('15', 'Non-Fixed Object'),
            ('16', 'Railcar - Vehicle'),
            ('99', 'Other')$q1$, lookup_schema);

        -- TODO: confirm order
        -- 2017 Crash Report Manual, p. 42 (numbers assumed from order given).        
        execute format($q1$ insert into %I.driven_left_towed (code, description) values
            ('1', 'Driven'),
            ('2', 'Left at Scene'),
            ('3', 'Towed Disabled'),
            ('4', 'Towed Impounded'),
            ('5', 'Towed Disabled & Impounded')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 51.
        execute format($q1$ insert into %I.ejection (code, description) values
            ('00', 'Unknown'),
            ('01', 'Not Ejected'),
            ('02', 'Partial Ejection'),
            ('03', 'Ejected'),
            ('04', 'Trapped'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 65.
        execute format($q1$ insert into %I.environmental_condition (code, description) values
            ('00', 'Unknown'),
            ('01', 'Clear'),
            ('02', 'Rain'),
            ('03', 'Snow'),
            ('04', 'Fog/Smog/Smoke'),
            ('05', 'Overcast'),
            ('06', 'Sleet/Hail'),
            ('07', 'Freezing Rain'),
            ('08', 'Blowing Snow'),
            ('09', 'Blowing Sand/Dirt'),
            ('10', 'Severe Crosswinds'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 96.
        execute format($q1$ insert into %I.extent_of_damage (code, description) values
            ('00', 'Unknown'),
            ('01', 'None'),
            ('02', 'Minor'),
            ('03', 'Moderate/Functional'),
            ('04', 'Disabling'),
            ('99', 'Other')$q1$, lookup_schema);

        -- TODO: confirm
        -- Assumed from NJTR-1 form, box 49.
        execute format($q1$ insert into %I.hazmat_status (code, description) values
            ('N', 'None'),
            ('O', 'On Board'),
            ('S', 'Spill')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 62.
        execute format($q1$ insert into %I.light_condition (code, description) values
            ('00', 'Unknown'),
            ('01', 'Daylight'),
            ('02', 'Dawn'),
            ('03', 'Dusk'),
            ('04', 'Dark (street lights off)'),
            ('05', 'Dark (no street lights)'),
            ('06', 'Dark (street lights on, continuous lighting)'),
            ('07', 'Dark (street lights on, spot lighting)'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 54.
        execute format($q1$ insert into %I.location_of_most_severe_injury (code, description) values
            ('00', 'Unknown'),
            ('01', 'Head'),
            ('02', 'Face'),
            ('03', 'Eye'),
            ('04', 'Neck'),
            ('05', 'Chest'),
            ('06', 'Back'),
            ('07', 'Shoulder/Upper Arm'),
            ('08', 'Elbow/Lower Arm/Hand'),
            ('09', 'Abdomen/Pelvis'),
            ('10', 'Hip/Upper Leg'),
            ('11', 'Knee/Lower Leg/Foot'),
            ('12', 'Entire Body'),
            ('99', 'Other')$q1$, lookup_schema);

        /*
        This is in all tables, but split between county code and municipality code.
        However, as the 2017 Crash Report Manual, p. 18, states, it is the 4-digit National Crime
        Information Center Municipality Code. The first two digits are the county, and the second
        two digits are the municipality. Because the municipality code starts at 01 for each county,
        they have to be used together, and so they are combined into one field in our db rather
        than two.
        NJ available at <https://dot.nj.gov/transportation/refdata/accident/pdf/CountyMunicipalCodes1-13-17.pdf>
        */
        execute format($q1$ insert into %I.ncic (code, description) values
            -- 03 is Burlington County
            ('0301', 'Bass River Twp'),
            ('0302', 'Beverly City'),
            ('0303', 'Bordentown City'),
            ('0304', 'Bordentown Twp'),
            ('0305', 'Burlington City'),
            ('0306', 'Burlington Twp'),
            ('0307', 'Chesterfield Twp'),
            ('0308', 'Cinnaminson Twp'),
            ('0309', 'Delanco Twp'),
            ('0310', 'Delran Twp'),
            ('0311', 'Eastampton Twp'),
            ('0312', 'Edgewater Park Twp'),
            ('0313', 'Evesham Twp'),
            ('0314', 'Fieldsboro Boro'),
            ('0315', 'Florence Twp'),
            ('0316', 'Hainesport Twp'),
            ('0317', 'Lumberton Twp'),
            ('0318', 'Mansfield Twp'),
            ('0319', 'Maple Shade Twp'),
            ('0320', 'Medford Twp'),
            ('0321', 'Medford Lakes Boro'),
            ('0322', 'Moorestown Twp'),
            ('0323', 'Mount Holly Twp'),
            ('0324', 'Mount Laurel Twp'),
            ('0325', 'New Hanover Twp'),
            ('0326', 'North Hanover Twp'),
            ('0327', 'Palmyra Boro'),
            ('0328', 'Pemberton Boro'),
            ('0329', 'Pemberton Twp'),
            ('0330', 'Riverside Twp'),
            ('0331', 'Riverton Boro'),
            ('0332', 'Shamong Twp'),
            ('0333', 'Southampton Twp'),
            ('0334', 'Springfield Twp'),
            ('0335', 'Tabernacle Twp'),
            ('0336', 'Washington Twp'),
            ('0337', 'Westampton Twp'),
            ('0338', 'Willingboro Twp'),
            ('0339', 'Woodland Twp'),
            ('0340', 'Wrightstown Boro'),
            -- 04 is Camden County
            ('0401', 'Audubon Boro'),
            ('0402', 'Audubon Park Boro'),
            ('0403', 'Barrington Boro'),
            ('0404', 'Bellmawr Boro'),
            ('0405', 'Berlin Boro'),
            ('0406', 'Berlin Twp'),
            ('0407', 'Brooklawn Boro'),
            ('0408', 'Camden City'),
            ('0409', 'Cherry Hill Twp'),
            ('0410', 'Chesilhurst Boro'),
            ('0411', 'Clementon Boro'),
            ('0412', 'Collingswood Boro'),
            ('0413', 'Gibbsboro Boro'),
            ('0414', 'Gloucester City'),
            ('0415', 'Gloucester Twp'),
            ('0416', 'Haddon Twp'),
            ('0417', 'Haddonfield Boro'),
            ('0418', 'Haddon Heights Boro'),
            ('0419', 'Hi-Nella Boro'),
            ('0420', 'Laurel Springs Boro'),
            ('0421', 'Lawnside Boro'),
            ('0422', 'Lindenwold Boro'),
            ('0423', 'Magnolia Boro'),
            ('0424', 'Merchantville Boro'),
            ('0425', 'Mount Ephriam Boro'),
            ('0426', 'Oaklyn Boro'),
            ('0427', 'Pennsauken Twp'),
            ('0428', 'Pine Hill Boro'),
            ('0429', 'Pine Valley Boro'),
            ('0430', 'Runnemede Boro'),
            ('0431', 'Somerdale Boro'),
            ('0432', 'Stratford Boro'),
            ('0433', 'Tavistock Boro'),
            ('0434', 'Voorhees Twp'),
            ('0435', 'Waterford Twp'),
            ('0436', 'Winslow Twp'),
            ('0437', 'Woodlynne Boro'),
            -- 08 is Gloucester
            ('0801', 'Clayton Boro'),
            ('0802', 'Deptford Twp'),
            ('0803', 'East Greenwich Twp'),
            ('0804', 'Elk Twp'),
            ('0805', 'Franklin Twp'),
            ('0806', 'Glassboro Boro'),
            ('0807', 'Greenwich Twp'),
            ('0808', 'Harrison Twp'),
            ('0809', 'Logan Twp'),
            ('0810', 'Mantua Twp'),
            ('0811', 'Monroe Twp'),
            ('0812', 'National Park Boro'),
            ('0813', 'Newfield Boro'),
            ('0814', 'Paulsboro Boro'),
            ('0815', 'Pitman Boro'),
            ('0816', 'South Harrison Twp'),
            ('0817', 'Swedesboro Boro'),
            ('0818', 'Washington Twp'),
            ('0819', 'Wenonah Boro'),
            ('0820', 'West Deptford Twp'),
            ('0821', 'Westville Boro'),
            ('0822', 'Woodbury City'),
            ('0823', 'Woodbury Heights Boro'),
            ('0824', 'Woolwich Twp'),
            -- 11 is Mercer
            ('1101', 'East Windsor Twp'),
            ('1102', 'Ewing Twp'),
            ('1103', 'Hamilton Twp'),
            ('1104', 'Hightstown Boro'),
            ('1105', 'Hopewell Boro'),
            ('1106', 'Hopewell Twp'),
            ('1107', 'Lawrence Twp'),
            ('1108', 'Pennington Boro'),
            ('1109', 'Princeton Boro'),
            ('1110', 'Princeton Twp'),
            ('1111', 'Trenton City'),
            ('1112', 'Robbinsville Twp'),
            ('1113', 'West Windsor Twp'),
            ('1114', 'Princeton')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 71.
        execute format($q1$ insert into %I.oversized_overweight_permit (code, description) values
            ('00', 'Unknown'),
            ('01', 'Yes'),
            ('02', 'No'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 50.
        execute format($q1$ insert into %I.position_in_veh (code, description) values
            ('00', 'Unknown'),
            ('01', 'Driver'),
            ('02', 'Passenger'),
            ('03', 'Passenger'),
            ('04', 'Passenger'),
            ('05', 'Passenger'),
            ('06', 'Passenger'),
            ('07', 'Passenger'),
            ('08', 'Passenger'),
            ('09', 'Passenger'),
            ('10', 'Cargo Area'),
            ('11', 'Riding/Hanging on Outside'),
            ('12', 'Bus Seating'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 17.
        -- NJTR-1 form, Box 2. 
        execute format($q1$ insert into %I.police_dept (code, description) values
            ('00', 'Unknown'),
            ('01', 'Municipal Police'),
            ('02', 'State Police'),
            ('03', 'County Police'),
            ('04', 'Port Authority Police'),
            ('05', 'County Sheriff'),
            ('99', 'Other Police')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 86.
        execute format($q1$ insert into %I.pre_crash_action (code, description) values
            ('00', 'Unknown'),
            -- Vehicle/Pedalcyclist Action (01-29)
            ('01', 'Going Straight Ahead'),
            ('02', 'Making Right Turn (not turn on red)'),
            ('03', 'Making Left Turn'),
            ('04', 'Making U-Turn'),
            ('05', 'Starting From Parking'),
            ('06', 'Starting in Traffic'),
            ('07', 'Slowing or Stopping'),
            ('08', 'Stopped in Traffic'),
            ('09', 'Parking'),
            ('10', 'Parked'),
            ('11', 'Changing Lanes'),
            ('12', 'Merging/Entering Traf Lane'),
            ('13', 'Backing'),
            ('14', 'Driverless/Moving'),
            ('15', 'Passing'),
            ('16', 'Negotiating Curve'),
            ('17', 'Driving on Shoulder'),
            ('18', 'Right Turn on Red'),
            ('19', 'Deliberate Action'),
            ('29', 'Other Veh/Cyclist Action'),
            -- Pedestrian Action (31-49)
            ('31', 'Pedestrian off Road'),
            ('32', 'Walking To/From School'),
            ('33', 'Walking/Jogging With Traffic'),
            ('34', 'Walking/Jogging Against Traffic'),
            ('35', 'Playing in Road'),
            ('36', 'Standing/Lying/Kneeling on Road'),
            ('37', 'Getting On/Off Vehicle'),
            ('38', 'Pushing/Working on Vehicle'),
            ('39', 'Other Working in Roadway'),
            ('40', 'Approaching/Leaving School Bus'),
            ('41', 'Coming From Behind Parked Veh'),
            ('42', 'Crossing/Jaywalking'),
            ('43', 'Crossing at "Marked" Crosswalk at Intersection'),
            ('44', 'Crossing at "Unmarked" Crosswalk at Intersection'),
            ('45', 'Crossing at "Marked" Crosswalk at Mid-Block'),
            ('46', 'Deliberate Action'),
            ('49', 'Other Pedestrian Action'),
            --
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 56.
        execute format($q1$ insert into %I.refused_med_attn (code, description) values
            ('00', 'Unknown'),
            ('01', 'Yes'),
            ('02', 'No'),
            ('99', 'Other')$q1$, lookup_schema);

        -- TODO: confirm these are correct
        -- 2017 Crash Report Manual (p. 43) and the NJTR-1 form have a box for each of these
        -- values to be checked, but the corresponding number isn't explicitly listed.
        execute format($q1$ insert into %I.removed_by (code, description) values
            ('1', 'Owner'),
            ('2', 'Driver'),
            ('3', 'Police')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 61.
        execute format($q1$ insert into %I.road_divided_by (code, description) values
            ('00', 'Unknown'),
            ('01', 'Barrier Median'),
            ('02', 'Curbed Median'),
            ('03', 'Grass Median'),
            ('04', 'Painted Median'),
            ('05', 'None'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 63.
        execute format($q1$ insert into %I.road_grade (code, description) values
            ('00', 'Unknown'),
            ('04', 'Level'),
            ('05', 'Down Hill'),
            ('06', 'Up Hill'),
            ('07', 'Hill Crest'),
            ('08', 'Sag (Bottom)'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 63.
        execute format($q1$ insert into %I.road_horizontal_alignment (code, description) values
            ('00', 'Unknown'),
            ('01', 'Straight'),
            ('02', 'Curved Left'),
            ('03', 'Curved Right'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 65.
        execute format($q1$ insert into %I.road_surface_condition (code, description) values
            ('00', 'Unknown'),
            ('01', 'Dry'),
            ('02', 'Wet'),
            ('03', 'Snowy'),
            ('04', 'Icy'),
            ('05', 'Slush'),
            ('06', 'Water (Standing/moving)'),
            ('07', 'Sand'),
            ('08', 'Oil/Fuel'),
            ('09', 'Mud, Dirt, Gravel'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 64.
        execute format($q1$ insert into %I.road_surface_type (code, description) values
            ('00', 'Unknown'),
            ('01', 'Concrete'),
            ('02', 'Blacktop'),
            ('03', 'Gravel'),
            ('04', 'Steel Grid'),
            ('05', 'Dirt'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 63.
        execute format($q1$ insert into %I.road_system (code, description) values
            ('00', 'Unknown'),
            ('01', 'Interstate'),
            ('02', 'State Highway'),
            ('03', 'State/Interstate Authority'),
            ('04', 'State Park or Institution'),
            ('05', 'County'),
            ('06', 'Co Auth, Park or Inst'),
            ('07', 'Municipal'),
            ('08', 'Mun Auth, Park or Inst'),
            ('09', 'Private Property'),
            ('10', 'US Govt Property'),
            ('99', 'Other')$q1$, lookup_schema);
        
        -- From <https://dot.nj.gov/transportation/refdata/accident/codes.shtm>
        execute format($q1$ insert into %I.route_suffix (code, description) values
            ('00', 'Unknown'),
            ('A', 'Alternate'),
            ('B', 'Business'),
            ('C', 'Freeway'),
            ('M', 'Mercer Alignment (I-95 Only)'),
            ('P', 'Pennsylvania Extension (NJTPK Only)'),
            ('S', 'Spur (County Routes Only)'),
            ('T', 'Truck (Route 1 & 9 Only)'),
            ('U', 'Upper (State Route 139 Only)'),
            ('L', 'Lower (State Route 139 Only)'),
            ('W', 'Western Alignment (NJTPK, Route 9 & Route 173)'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 57.
        execute format($q1$ insert into %I.safety_equipment (code, description) values
            ('00', 'Unknown'),
            ('01', 'None'),
            ('02', 'Lap Belt'),
            ('03', 'Harness'),
            ('04', 'Lap Belt & Harness'),
            ('05', 'Child Restraint - Forward Facing'),
            ('06', 'Child Restraint - Rear Facing'),
            ('07', 'Child Restraint - Booster'),
            ('08', 'Helmet'),
            ('09', 'Unapproved Helmet'),
            ('10', 'Airbag'),
            ('11', 'Airbag & Seatbelts'),
            ('12', 'Safety Vest (Ped only)'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, pp 90-3.
        execute format($q1$ insert into %I.sequence_of_events (code, description) values
            ('00', 'Unknown'),
            -- Non-Collision (01-19)
            ('01', 'Overturn/Rollover'),
            ('02', 'Fire/Explosion'),
            ('03', 'Immersion'),
            ('04', 'Jackknife'),
            ('05', 'Ran Off Road - Right'),
            ('06', 'Ran Off Road - Left'),
            ('07', 'Cross Median'),
            ('08', 'Crossed Centerline'),
            ('09', 'Cargo/Equipment Loss or Shift'),
            ('10', 'Separation of Units'),
            ('11', 'Fell/Jumped From Vehicle'),
            ('12', 'Thrown/Fallen/Falling Object'),
            ('13', 'Equipment Failure'),
            ('14', 'Downhill/Runaway'),
            ('15', 'Reentered Roadway'),
            ('19', 'Other Non-Collision'),
            -- Collision w/ Person, MV, or Non-Fixed Object (21-39)
            ('21', 'Pedalcyclist'),
            ('22', 'Pedestrian'),
            ('23', 'Train/Trolley/Other Railcar'),
            ('24', 'Deer'),
            ('25', 'Other Animal'),
            ('26', 'MV in Transport'),
            ('27', 'MV in Transport, Other Roadway'),
            ('28', 'Parked MV'),
            ('29', 'Work Zone or Maint Equipment'),
            ('30', 'Struck by Object Set in Motion by MV'),
            ('39', 'Other Non-Fixed Object'),
            -- Collision w/ Fixed Object (41-69)
            ('41', 'Impact Attenuator/Crash Cushion'),
            ('42', 'Bridge Overhead Structure'),
            ('43', 'Bridge Pier or Support'),
            ('44', 'Bridge Parapet End'),
            ('45', 'Bridge Rail'),
            ('46', 'Guide Rail Face'),
            ('47', 'Guide Rail End'),
            ('48', 'Concrete Traffic Barrier'),
            ('49', 'Other Traffic Barrier'),
            ('50', 'Traffic Sign Support'),
            ('51', 'Traffic Signal Standard'),
            ('52', 'Utility Pole'),
            ('53', 'Light Standard'),
            ('54', 'Other Post, Pole, Support'),
            ('55', 'Culvert'),
            ('56', 'Curb'),
            ('57', 'Ditch'),
            ('58', 'Embankment'),
            ('59', 'Fence'),
            ('60', 'Tree'),
            ('61', 'Mailbox'),
            ('62', 'Fire Hydrant'),
            ('69', 'Other Fixed Object'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, pp 52-3.
        -- NJTR-1 form, Box 86
        execute format($q1$ insert into %I.physical_condition (code, description) values
            ('00', 'Unknown'),
            ('01', 'Fatal Injury'),
            ('02', 'Suspected Serious Injury'),
            ('03', 'Suspected Minor Injury'),
            ('04', 'Possible Injury'),
            ('05', 'No Apparent Injury'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 85.
        -- Box 120/121 on form.
        execute format($q1$ insert into %I.physical_status (code, description) values
            ('00', 'Unknown'),
            ('01', 'Apparently Normal'),
            ('02', 'Alcohol Use'),
            ('03', 'Drug Use (Illicit)'),
            ('04', 'Medication'),
            ('05', 'Alcohol & Drug Medication Use'),
            ('06', 'Physical Handicaps'),
            ('07', 'Illness'),
            ('08', 'Fatigue'),
            ('09', 'Fell Asleep'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 75.
        execute format($q1$ insert into %I.special_function_vehicles (code, description) values
            ('00', 'Unknown'),
            ('01', 'Work Equipment'),
            ('02', 'Police'),
            ('03', 'Military'),
            ('04', 'Fire/Rescue'),
            ('05', 'Ambulance'),
            ('06', 'Taxi/Limo'),
            ('07', 'Veh Used as School Bus'),
            ('08', 'Veh Used as Other Bus'),
            ('09', 'School Bus'),
            ('10', 'Transit Bus'),
            ('11', 'Tour Bus'),
            ('12', 'Shuttle Bus'),
            ('13', 'Intercity Bus'),
            ('14', 'Other Bus'),
            ('15', 'Veh Used as Snowplow'),
            ('16', 'Tow Truck'),
            ('17', 'Farm Equipment'),
            ('18', 'Farm Vehicle'),
            ('19', 'Construction/Off Road Equip'),
            ('20', 'Rental Truck (Over 10,000 lbs)'),
            ('99', 'Other')$q1$, lookup_schema);

        -- Assumed from NJTR-1 form, box 15.
        execute format($q1$ insert into %I.unit_of_measure (code, description) values
            ('FE', 'Feet'),
            ('MI', 'Miles'),
            ('AT', 'At Intersection With')$q1$, lookup_schema);

        
        -- 2017 Crash Report Manual, p. 61.
        execute format($q1$ insert into %I.temp_traffic_control_zone (code, description) values
            ('00', 'Unknown'),
            ('01', 'No'),
            ('02', 'Yes - Construction Zone'),
            ('03', 'Yes - Maintenance Zone'),
            ('04', 'Yes - Utility Zone'),
            ('05', 'Yes - Incident Zone'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 89.
        execute format($q1$ insert into %I.traffic_controls (code, description) values
            ('00', 'Unknown'),
            ('01', 'Police Officer'),
            ('02', 'RR Watchmen, Gates, etc'),
            ('03', 'Traffic Signal'),
            ('04', 'Lane Markings'),
            ('05', 'Channelization - Painted'),
            ('06', 'Channelization - Physical'),
            ('07', 'Warning Signal'),
            ('08', 'Stop Sign'),
            ('09', 'Yield Sign'),
            ('10', 'Flagmen'),
            ('11', 'No Control Present'),
            ('12', 'Flashing Traffic Control'),
            ('13', 'School Zone (Signs/Controls)'),
            ('14', 'Adult Crossing Guard'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 55. 
        execute format($q1$ insert into %I.type_of_most_severe_injury (code, description) values
            ('00', 'Unknown'),
            ('01', 'Amputation'),
            ('02', 'Concussion'),
            ('03', 'Internal'),
            ('04', 'Bleeding'),
            ('05', 'Contusion/Bruise/Abrasion'),
            ('06', 'Burn'),
            ('07', 'Fracture/Dislocation'),
            ('08', 'Complaint of Pain'),
            ('99', 'Other')$q1$, lookup_schema);

        -- NJTR-1 overlay.
        execute format($q1$ insert into %I.veh_color (code, description) values
            ('BG', 'Beige'),
            ('BK', 'Black'),
            ('BL', 'Blue'),
            ('BN', 'Brown'),
            ('CL', 'Coral'),
            ('CM', 'Cream'),
            ('GD', 'Gold'),
            ('GY', 'Gray'),
            ('GN', 'Green'),
            ('MN', 'Maroon'),
            ('OG', 'Orange'),
            ('PK', 'Pink'),
            ('PL', 'Purple'),
            ('RD', 'Red'), 
            ('SL', 'Silver'),
            ('TN', 'Tan'), 
            ('TQ', 'Turquoise'),
            ('WT', 'White'),
            ('YL', 'Yellow')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 95.
        execute format($q1$ insert into %I.veh_impact_area (code, description) values
            ('00', 'Unknown'),
            ('01', '1 o''clock'),
            ('02', '2 o''clock'),
            ('03', '3 o''clock'),
            ('04', '4 o''clock'),
            ('05', '5 o''clock'),
            ('06', '6 o''clock'),
            ('07', '7 o''clock'),
            ('08', '8 o''clock'),
            ('09', '9 o''clock'),
            ('10', '10 o''clock'),
            ('11', '11 o''clock'),
            ('12', '12 o''clock'),
            ('13', 'Roof'),
            ('14', 'Undercarriage'),
            ('15', 'Overturned'),
            ('17', 'None Visible'),
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, pp 71-3.
        execute format($q1$ insert into %I.veh_type (code, description) values
            ('00', 'Unknown'),
            -- Passenger Vehicles (01-19)
            ('01', 'Car/Station Wagon/Minivan'),
            ('02', 'Passenger Van (<9 Seats)'),
            ('03', 'Cargo Van (10K lbs or less)'),
            ('04', 'Sport Utility Vehicle'),
            ('05', 'Pick up'),
            ('06', 'Recreational Vehicle'),
            ('07', 'All Terrain Vehicle'),
            ('08', 'Motorcycle'),
            ('09', '(reserved)'),
            ('10', 'Any previous w/Trailer'),
            ('11', 'Moped'),
            ('12', 'Streetcar/Trolley'),
            ('13', 'Pedalcycle'),
            ('14', 'Golf Cart'),
            ('15', 'Low Speed Vehicle'),
            ('16', 'Snowmobile'),
            ('19', 'Other Pass Vehicle'),
            -- Trucks (20-29)
            ('20', 'Single Unit (2 axle)'),
            ('21', 'Single Unit (3 axle)'),
            ('22', 'Truck 2 Axle w/Trailer'),
            ('23', 'Truck 3+ Axle w/Trailer'),
            ('24', 'Truck Tractor (Bobtail)'),
            ('25', 'Tractor Semi-Trailer'),
            ('26', 'Tractor Double'),
            ('27', 'Tractor Triple'),
            ('29', 'Other Truck'),
            -- Bus (30-31)
            ('30', 'Bus/Large Van/Limo (9-15 Seats)'),
            ('31', 'Bus (More than 15 Seats)'),
            -- Other Non Pass (40)
            ('40', 'Equipment/Machinery'),
            --
            ('99', 'Other')$q1$, lookup_schema);

        -- 2017 Crash Report Manual, p. 74.
        execute format($q1$ insert into %I.veh_use (code, description) values
            ('00', 'Unknown'),
            ('01', 'Personal'),
            ('02', 'Business/Commerce'),
            ('03', 'Government'),
            ('04', 'Responding to Emergency'),
            ('05', 'Machinery in Use'),
            ('99', 'Other')$q1$, lookup_schema);

        -- NJ Crash Report Manual, pp 46-7.
        execute format($q1$ insert into %I.veh_weight_rating (code, description) values
            ('1', '<= 10,000 lbs'),
            ('2', '10,0001 to 26,000 lbs'),
            ('3', '>= 26,001 lbs')$q1$, lookup_schema);
        
        -- execute format($q1$ insert into %I. (code, description) values
        --     ('00', 'Unknown'),
        --     ('01', ''),
        --     ('02', ''),
        --     ('03', ''),
        --     ('04', ''),
        --     ('05', ''),
        --     ('06', ''),
        --     ('07', ''),
        --     ('08', ''),
        --     ('09', ''),
        --     ('10', ''),
        --     ('11', ''),
        --     ('12', ''),
        --     ('13', ''),
        --     ('14', ''),
        --     ('15', ''),
        --     ('16', ''),
        --     ('17', ''),
        --     ('18', ''),
        --     ('19', ''),
        --     ('20', ''),
        --     ('99', 'Other')$q1$, lookup_schema);
        -- 
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

end;
$body$
