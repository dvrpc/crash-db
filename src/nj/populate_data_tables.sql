create or replace procedure nj_populate_data_tables(year text)
language plpgsql
as
$body$
declare
    user_data_dir text = current_setting('myvars.user_data_dir');
    postgres_data_dir text = current_setting('myvars.postgres_data_dir');
    col_name text;
    dat_type text;
    db_tables text[] = '{crash, driver, occupant, pedestrian, vehicle}';
    db_table text;
    counties text[] = '{Burlington, Camden, Gloucester, Mercer}';
    county text;
    line text;

begin

    raise info '.Create temporary tables to insert all columns as one column';
    foreach db_table in array db_tables loop
        execute format($tt$create temporary table temp_%s_%s_one_column (one_column text) on commit drop$tt$, db_table, year, year, db_table);
    end loop;

    
    raise info '.Copy data into the one-column temporary tables';
    foreach db_table in array db_tables loop
        -- The data files use "Accident" but the table name is "crash".
        if db_table = 'crash' then
            foreach county in array counties loop
                execute format($q$copy temp_%s_%s_one_column from '%s/nj/%s%sAccidents.txt' with (format text)$q$, db_table, year, user_data_dir, county, year);
            end loop;
        else
            foreach county in array counties loop
                execute format($q$copy temp_%s_%s_one_column from '%s/nj/%s%s%ss.txt' with (format text)$q$, db_table, year, user_data_dir, county, year, initcap(db_table));
            end loop;
        end if;
    end loop;

    raise info '.Create temporary tables for cleaning data';
    foreach db_table in array db_tables loop
        execute format($tt$create temporary table temp_%s_%s (like nj_%s.%I including all) on commit drop$tt$, db_table, year, year, db_table);
    end loop;

    /*
        Change field types in the temp tables to text so they'll accept all data (to fix later).
        For those that will be booleans, use the broadest domain that can be unambiguously converted
        to booleans (in cleaning data fn).
    */
    raise info '.Change field types in temp tables';
    foreach db_table in array db_tables loop
    	for col_name, dat_type in select column_name, data_type from information_schema.columns where table_name = 'temp_' || db_table || '_' || year and data_type != 'text' loop
            if dat_type = 'boolean' then
                execute format($q$alter table temp_%I_%s alter column %I type text019YNTFUspace_as_bool using %I::text019YNTFUspace_as_bool$q$, db_table, year, col_name, col_name);
            else
                execute format($q$alter table temp_%I_%s alter column %I type text$q$, db_table, year, col_name);
            end if;
        end loop;
    end loop;

    /*
      If data population into the temp tables failed (below) because of a bad value, alter the
      type to determine what it is, so it can be inserted and then cleaned later.
    */
    raise info '.Alter domains';
    call nj_alter_temp_domains(year);

    /* NOTE: The Drivers and Pedestrians tables in the 2021 and 2022 files do no match the 
    file specification: DOB has length of 0 rather than 10, so there is a condition for those
    tables to check the year and handle appropriately.
    */
    raise info '.Parse columns from spec & insert into second set of temporary tables';
    foreach db_table in array db_tables loop
        for line in execute format($q1$select one_column from temp_%s_%s_one_column$q1$, db_table, year) loop
            if db_table = 'crash' then
                execute format($q2$insert into temp_%1$s_%2$s values (
                    nullif(trim(substring(%3$s from 1 for 4)), ''),    -- year
                    nullif(trim(substring(%3$s from 5 for 4)), ''),    -- ncic (county & muni) code
                    nullif(trim(substring(%3$s from 9 for 23)), ''),   -- dept case num
                    nullif(trim(substring(%3$s from 33 for 12)), ''),  -- county name
                    nullif(trim(substring(%3$s from 46 for 24)), ''),  -- municipality name
                    nullif(trim(substring(%3$s from 71 for 10)), ''),  -- crash date
                    nullif(trim(substring(%3$s from 82 for 2)), ''),   -- crash day of week
                    nullif(trim(substring(%3$s from 85 for 4)), ''),   -- crash time
                    nullif(trim(substring(%3$s from 90 for 2)), ''),   -- police dept code
                    nullif(trim(substring(%3$s from 93 for 25)), ''),  -- police dept
                    nullif(trim(substring(%3$s from 119 for 15)), ''), -- police station
                    nullif(trim(substring(%3$s from 135 for 2)), ''),  -- total killed
                    nullif(trim(substring(%3$s from 138 for 2)), ''),  -- total injured
                    nullif(trim(substring(%3$s from 141 for 2)), ''),  -- pedestrians killed
                    nullif(trim(substring(%3$s from 144 for 2)), ''),  -- pedestrians injured
                    nullif(trim(substring(%3$s from 147 for 1)), ''),  -- severity
                    nullif(trim(substring(%3$s from 149 for 1)), ''),  -- intersection
                    nullif(trim(substring(%3$s from 151 for 1)), ''),  -- alcohol involved
                    nullif(trim(substring(%3$s from 153 for 1)), ''),  -- hazmat involved
                    nullif(trim(substring(%3$s from 155 for 2)), ''),  -- crash type code
                    nullif(trim(substring(%3$s from 158 for 2)), ''),  -- total vehs involved
                    nullif(trim(substring(%3$s from 161 for 50)), ''), -- crash location
                    nullif(trim(substring(%3$s from 212 for 1)), ''),  -- location direction
                    nullif(trim(substring(%3$s from 214 for 4)), ''),  -- route
                    nullif(trim(substring(%3$s from 219 for 1)), ''),  -- route suffix
                    nullif(trim(substring(%3$s from 221 for 16)), ''), -- sri
                    nullif(trim(substring(%3$s from 238 for 7)), ''),  -- milepost
                    nullif(trim(substring(%3$s from 246 for 2)), ''),  -- road system
                    nullif(trim(substring(%3$s from 249 for 2)), ''),  -- road character
                    nullif(trim(substring(%3$s from 252 for 2)), ''),  -- road horizontal alignment
                    nullif(trim(substring(%3$s from 255 for 2)), ''),  -- road grade
                    nullif(trim(substring(%3$s from 258 for 2)), ''),  -- road surface type
                    nullif(trim(substring(%3$s from 261 for 2)), ''),  -- surface condition
                    nullif(trim(substring(%3$s from 264 for 2)), ''),  -- light condition
                    nullif(trim(substring(%3$s from 267 for 2)), ''),  -- environmental condition
                    nullif(trim(substring(%3$s from 270 for 2)), ''),  -- road divided by
                    nullif(trim(substring(%3$s from 273 for 2)), ''),  -- temp traffic control zone
                    nullif(trim(substring(%3$s from 276 for 4)), ''),  -- distance to cross street
                    nullif(trim(substring(%3$s from 281 for 2)), ''),  -- unit of measurement
                    nullif(trim(substring(%3$s from 284 for 1)), ''),  -- direction from cross street
                    nullif(trim(substring(%3$s from 286 for 35)), ''), -- cross street name
                    nullif(trim(substring(%3$s from 322 for 1)), ''),  -- is ramp
                    nullif(trim(substring(%3$s from 324 for 25)), ''), -- ramp to/from route name
                    nullif(trim(substring(%3$s from 350 for 2)), ''),  -- ramp to/from route direction
                    nullif(trim(substring(%3$s from 353 for 2)), ''),  -- posted speed
                    nullif(trim(substring(%3$s from 356 for 2)), ''),  -- posted speed at cross street
                    nullif(trim(substring(%3$s from 359 for 2)), ''),  -- first harmful event
                    nullif(trim(substring(%3$s from 362 for 9)), ''),  -- latitude
                    nullif(trim(substring(%3$s from 372 for 9)), ''),  -- longitude
                    nullif(trim(substring(%3$s from 382 for 1)), ''),  -- cell phone in use flag
                    nullif(trim(substring(%3$s from 384 for 80)), ''), -- other property damage
                    nullif(trim(substring(%3$s from 465 for 5)), '')   -- reporting badge no
                )$q2$, db_table, year, quote_nullable(line));
            elseif db_table = 'driver' then
                -- 2021 and 2022 not to spec, use null for DOB
                if year in ('2021', '2022') then
                    execute format($q2$insert into temp_%1$s_%2$s values (
                        nullif(trim(substring(%3$s from 1 for 4)), ''),    -- year
                        nullif(trim(substring(%3$s from 5 for 4)), ''),    -- ncic (county & muni) code
                        nullif(trim(substring(%3$s from 9 for 23)), ''),   -- dept case no
                        nullif(trim(substring(%3$s from 33 for 2)), ''),   -- veh num
                        nullif(trim(substring(%3$s from 36 for 25)), ''),  -- driver city
                        nullif(trim(substring(%3$s from 62 for 2)), ''),   -- driver state
                        nullif(trim(substring(%3$s from 65 for 5)), ''),   -- driver zip code
                        nullif(trim(substring(%3$s from 71 for 2)), ''),   -- driver license state
                        null,                                              -- driver DOB
                        nullif(trim(substring(%3$s from 75 for 1)), ''),   -- driver sex
                        nullif(trim(substring(%3$s from 77 for 1)), ''),   -- alcohol test given
                        nullif(trim(substring(%3$s from 79 for 2)), ''),   -- alcohol test type
                        nullif(trim(substring(%3$s from 82 for 3)), ''),   -- alcohol test results
                        nullif(trim(substring(%3$s from 86 for 30)), ''),  -- charge 1
                        nullif(trim(substring(%3$s from 117 for 30)), ''), -- summons 1
                        nullif(trim(substring(%3$s from 148 for 30)), ''), -- charge 2
                        nullif(trim(substring(%3$s from 179 for 30)), ''), -- summons 2 
                        nullif(trim(substring(%3$s from 210 for 30)), ''), -- charge 3
                        nullif(trim(substring(%3$s from 241 for 30)), ''), -- summons 3
                        nullif(trim(substring(%3$s from 272 for 30)), ''), -- charge 4
                        nullif(trim(substring(%3$s from 303 for 30)), ''), -- summons 4
                        nullif(trim(substring(%3$s from 334 for 1)), ''),  -- multi charge flag
                        nullif(trim(substring(%3$s from 336 for 2)), ''),  -- driver physical status 1
                        nullif(trim(substring(%3$s from 339 for 2)), '')   -- driver physical status 2
                    )$q2$, db_table, year, quote_nullable(line));
                else
                    execute format($q2$insert into temp_%1$s_%2$s values (
                        nullif(trim(substring(%3$s from 1 for 4)), ''),    -- year
                        nullif(trim(substring(%3$s from 5 for 4)), ''),    -- ncic (county & muni) code
                        nullif(trim(substring(%3$s from 9 for 23)), ''),   -- dept case no
                        nullif(trim(substring(%3$s from 33 for 2)), ''),   -- veh num
                        nullif(trim(substring(%3$s from 36 for 25)), ''),  -- driver city
                        nullif(trim(substring(%3$s from 62 for 2)), ''),   -- driver state
                        nullif(trim(substring(%3$s from 65 for 5)), ''),   -- driver zip code
                        nullif(trim(substring(%3$s from 71 for 2)), ''),   -- driver license state
                        nullif(trim(substring(%3$s from 74 for 10)), ''),  -- driver DOB
                        nullif(trim(substring(%3$s from 85 for 1)), ''),   -- driver sex
                        nullif(trim(substring(%3$s from 87 for 1)), ''),   -- alcohol test given
                        nullif(trim(substring(%3$s from 89 for 2)), ''),   -- alcohol test type
                        nullif(trim(substring(%3$s from 92 for 3)), ''),   -- alcohol test results
                        nullif(trim(substring(%3$s from 96 for 30)), ''),  -- charge 1
                        nullif(trim(substring(%3$s from 127 for 30)), ''), -- summons 1
                        nullif(trim(substring(%3$s from 158 for 30)), ''), -- charge 2
                        nullif(trim(substring(%3$s from 189 for 30)), ''), -- summons 2 
                        nullif(trim(substring(%3$s from 220 for 30)), ''), -- charge 3
                        nullif(trim(substring(%3$s from 251 for 30)), ''), -- summons 3
                        nullif(trim(substring(%3$s from 282 for 30)), ''), -- charge 4
                        nullif(trim(substring(%3$s from 313 for 30)), ''), -- summons 4
                        nullif(trim(substring(%3$s from 344 for 1)), ''),  -- multi charge flag
                        nullif(trim(substring(%3$s from 346 for 2)), ''),  -- driver physical status 1
                        nullif(trim(substring(%3$s from 349 for 2)), '')   -- driver physical status 2
                    )$q2$, db_table, year, quote_nullable(line));
                end if;
            elseif db_table = 'occupant' then
                execute format($q2$insert into temp_%1$s_%2$s values (
                    nullif(trim(substring(%3$s from 1 for 4)), ''),    -- year
                    nullif(trim(substring(%3$s from 5 for 4)), ''),    -- ncic (county & muni) code
                    nullif(trim(substring(%3$s from 9 for 23)), ''),   -- dept case no
                    nullif(trim(substring(%3$s from 33 for 2)), ''),   -- veh num
                    nullif(trim(substring(%3$s from 36 for 2)), ''),   -- occupant number
                    nullif(trim(substring(%3$s from 39 for 2)), ''),   -- physical condition
                    nullif(trim(substring(%3$s from 42 for 2)), ''),   -- position in/on veh
                    nullif(trim(substring(%3$s from 45 for 2)), ''),   -- ejection code
                    nullif(trim(substring(%3$s from 48 for 3)), ''),   -- age
                    nullif(trim(substring(%3$s from 52 for 1)), ''),   -- sex
                    nullif(trim(substring(%3$s from 54 for 2)), ''),   -- location of most severe injury
                    nullif(trim(substring(%3$s from 57 for 2)), ''),   -- type of most severe injury
                    nullif(trim(substring(%3$s from 60 for 2)), ''),   -- refused medical attn 
                    nullif(trim(substring(%3$s from 63 for 2)), ''),   -- safety equip available
                    nullif(trim(substring(%3$s from 66 for 2)), ''),   -- safety equip used
                    nullif(trim(substring(%3$s from 69 for 2)), ''),   -- airbag deployment
                    nullif(trim(substring(%3$s from 72 for 4)), '')    -- hospital code
                )$q2$, db_table, year, quote_nullable(line));
            elseif db_table = 'pedestrian' then
                -- 2021 and 2022 not to spec, use null for DOB
                if year in ('2021', '2022') then
                    execute format($q2$insert into temp_%1$s_%2$s values (
                        nullif(trim(substring(%3$s from 1 for 4)), ''),    -- year
                        nullif(trim(substring(%3$s from 5 for 4)), ''),    -- ncic (county & muni) code
                        nullif(trim(substring(%3$s from 9 for 23)), ''),   -- dept case no
                        nullif(trim(substring(%3$s from 33 for 2)), ''),   -- pedestrian num
                        nullif(trim(substring(%3$s from 36 for 2)), ''),   -- physical condition
                        nullif(trim(substring(%3$s from 39 for 25)), ''),  -- address city
                        nullif(trim(substring(%3$s from 65 for 2)), ''),   -- address state
                        nullif(trim(substring(%3$s from 68 for 5)), ''),   -- address zip
                        null,                                              -- DOB
                        nullif(trim(substring(%3$s from 75 for 3)), ''),   -- age
                        nullif(trim(substring(%3$s from 79 for 1)), ''),   -- sex
                        nullif(trim(substring(%3$s from 81 for 1)), ''),   -- alcohol test given
                        nullif(trim(substring(%3$s from 83 for 2)), ''),   -- alcohol test type
                        nullif(trim(substring(%3$s from 86 for 3)), ''),   -- alcohol test results
                        nullif(trim(substring(%3$s from 90 for 30)), ''),  -- charge1
                        nullif(trim(substring(%3$s from 121 for 30)), ''), -- summons1
                        nullif(trim(substring(%3$s from 152 for 30)), ''), -- charge2
                        nullif(trim(substring(%3$s from 183 for 30)), ''), -- summons2
                        nullif(trim(substring(%3$s from 214 for 30)), ''), -- charge3
                        nullif(trim(substring(%3$s from 245 for 30)), ''), -- summons3
                        nullif(trim(substring(%3$s from 276 for 30)), ''), -- charge4
                        nullif(trim(substring(%3$s from 307 for 30)), ''), -- summons4
                        nullif(trim(substring(%3$s from 338 for 1)), ''),  -- multi-charge flag
                        nullif(trim(substring(%3$s from 340 for 2)), ''),  -- traffic controls
                        nullif(trim(substring(%3$s from 343 for 2)), ''),  -- contrib circumstances 1
                        nullif(trim(substring(%3$s from 346 for 2)), ''),  -- contrib circumstances 2
                        nullif(trim(substring(%3$s from 349 for 2)), ''),  -- direction of travel
                        nullif(trim(substring(%3$s from 352 for 2)), ''),   -- pre-crash action
                        nullif(trim(substring(%3$s from 355 for 2)), ''),   -- location of most severe injury
                        nullif(trim(substring(%3$s from 358 for 2)), ''),   -- type of most severe injury
                        nullif(trim(substring(%3$s from 361 for 2)), ''),   -- refused medical attn
                        nullif(trim(substring(%3$s from 364 for 2)), ''),   -- safety equipment used
                        nullif(trim(substring(%3$s from 367 for 4)), ''),   -- hospital code
                        nullif(trim(substring(%3$s from 372 for 2)), ''),   -- physical status 1
                        nullif(trim(substring(%3$s from 375 for 2)), ''),   -- physical status 2
                        nullif(trim(substring(%3$s from 378 for 1)), ''),   -- is bicyclist?
                        nullif(trim(substring(%3$s from 380 for 1)), '')    -- is other?
                    )$q2$, db_table, year, quote_nullable(line));
                else 
                    execute format($q2$insert into temp_%1$s_%2$s values (
                        nullif(trim(substring(%3$s from 1 for 4)), ''),    -- year
                        nullif(trim(substring(%3$s from 5 for 4)), ''),    -- ncic (county & muni) code
                        nullif(trim(substring(%3$s from 9 for 23)), ''),   -- dept case no
                        nullif(trim(substring(%3$s from 33 for 2)), ''),   -- pedestrian num
                        nullif(trim(substring(%3$s from 36 for 2)), ''),   -- physical condition
                        nullif(trim(substring(%3$s from 39 for 25)), ''),  -- address city
                        nullif(trim(substring(%3$s from 65 for 2)), ''),   -- address state
                        nullif(trim(substring(%3$s from 68 for 5)), ''),   -- address zip
                        nullif(trim(substring(%3$s from 74 for 10)), ''),  -- DOB
                        nullif(trim(substring(%3$s from 85 for 3)), ''),   -- age
                        nullif(trim(substring(%3$s from 89 for 1)), ''),   -- sex
                        nullif(trim(substring(%3$s from 91 for 1)), ''),   -- alcohol test given
                        nullif(trim(substring(%3$s from 93 for 2)), ''),   -- alcohol test type
                        nullif(trim(substring(%3$s from 96 for 3)), ''),   -- alcohol test results
                        nullif(trim(substring(%3$s from 100 for 30)), ''),  -- charge1
                        nullif(trim(substring(%3$s from 131 for 30)), ''), -- summons1
                        nullif(trim(substring(%3$s from 162 for 30)), ''), -- charge2
                        nullif(trim(substring(%3$s from 193 for 30)), ''), -- summons2
                        nullif(trim(substring(%3$s from 224 for 30)), ''), -- charge3
                        nullif(trim(substring(%3$s from 255 for 30)), ''), -- summons3
                        nullif(trim(substring(%3$s from 286 for 30)), ''), -- charge4
                        nullif(trim(substring(%3$s from 317 for 30)), ''), -- summons4
                        nullif(trim(substring(%3$s from 348 for 1)), ''),  -- multi-charge flag
                        nullif(trim(substring(%3$s from 350 for 2)), ''),  -- traffic controls
                        nullif(trim(substring(%3$s from 353 for 2)), ''),  -- contrib circumstances 1
                        nullif(trim(substring(%3$s from 356 for 2)), ''),  -- contrib circumstances 2
                        nullif(trim(substring(%3$s from 359 for 2)), ''),  -- direction of travel
                        nullif(trim(substring(%3$s from 362 for 2)), ''),   -- pre-crash action
                        nullif(trim(substring(%3$s from 365 for 2)), ''),   -- location of most severe injury
                        nullif(trim(substring(%3$s from 368 for 2)), ''),   -- type of most severe injury
                        nullif(trim(substring(%3$s from 371 for 2)), ''),   -- refused medical attn
                        nullif(trim(substring(%3$s from 374 for 2)), ''),   -- safety equipment used
                        nullif(trim(substring(%3$s from 377 for 4)), ''),   -- hospital code
                        nullif(trim(substring(%3$s from 382 for 2)), ''),   -- physical status 1
                        nullif(trim(substring(%3$s from 385 for 2)), ''),   -- physical status 2
                        nullif(trim(substring(%3$s from 388 for 1)), ''),   -- is bicyclist?
                        nullif(trim(substring(%3$s from 390 for 1)), '')    -- is other?
                    )$q2$, db_table, year, quote_nullable(line));
                end if;
            elseif db_table = 'vehicle' then
                execute format($q2$insert into temp_%1$s_%2$s values (
                    nullif(trim(substring(%3$s from 1 for 4)), ''),    -- year
                    nullif(trim(substring(%3$s from 5 for 4)), ''),    -- ncic (county & muni) code
                    nullif(trim(substring(%3$s from 9 for 23)), ''),   -- dept case no
                    nullif(trim(substring(%3$s from 33 for 2)), ''),   -- vehicle number
                    nullif(trim(substring(%3$s from 36 for 4)), ''),   -- insurance company code
                    nullif(trim(substring(%3$s from 41 for 2)), ''),   -- owner state
                    nullif(trim(substring(%3$s from 44 for 30)), ''),  -- make of vehicle
                    nullif(trim(substring(%3$s from 75 for 20)), ''),  -- model of vehicle
                    nullif(trim(substring(%3$s from 96 for 3)), ''),   -- color of vehicle
                    nullif(trim(substring(%3$s from 100 for 4)), ''),  -- year of vehicle
                    nullif(trim(substring(%3$s from 105 for 2)), ''),  -- license plate state
                    nullif(trim(substring(%3$s from 108 for 1)), ''),  -- vehicle weight rating
                    nullif(trim(substring(%3$s from 110 for 1)), ''),  -- towed
                    nullif(trim(substring(%3$s from 112 for 2)), ''),  -- removed by
                    nullif(trim(substring(%3$s from 115 for 1)), ''),  -- driven/left/towed
                    nullif(trim(substring(%3$s from 117 for 2)), ''),  -- initial impact location
                    nullif(trim(substring(%3$s from 120 for 2)), ''),  -- principal impact location
                    nullif(trim(substring(%3$s from 123 for 2)), ''),  -- extent of damage
                    nullif(trim(substring(%3$s from 126 for 2)), ''),  -- traffic controls present
                    nullif(trim(substring(%3$s from 129 for 2)), ''),  -- vehicle type
                    nullif(trim(substring(%3$s from 132 for 2)), ''),  -- vehicle use
                    nullif(trim(substring(%3$s from 135 for 2)), ''),  -- special function veh
                    nullif(trim(substring(%3$s from 138 for 2)), ''),  -- cargo body type
                    nullif(trim(substring(%3$s from 141 for 2)), ''),  -- contrib circumstance 1
                    nullif(trim(substring(%3$s from 144 for 2)), ''),  -- contrib circumstance 2
                    nullif(trim(substring(%3$s from 147 for 2)), ''),  -- direction of travel
                    nullif(trim(substring(%3$s from 150 for 2)), ''),  -- pre-crash action
                    nullif(trim(substring(%3$s from 153 for 2)), ''),  -- first seq of events
                    nullif(trim(substring(%3$s from 156 for 2)), ''),  -- second seq of events
                    nullif(trim(substring(%3$s from 159 for 2)), ''),  -- third seq of events
                    nullif(trim(substring(%3$s from 162 for 2)), ''),  -- fourth seq of events
                    nullif(trim(substring(%3$s from 165 for 2)), ''),  -- most harmful event
                    nullif(trim(substring(%3$s from 168 for 2)), ''),  -- oversize/overweight permit
                    nullif(trim(substring(%3$s from 171 for 1)), ''),  -- hazmat status
                    nullif(trim(substring(%3$s from 173 for 1)), ''),  -- hazmat class
                    nullif(trim(substring(%3$s from 175 for 10)), ''), -- hazmat placard
                    nullif(trim(substring(%3$s from 186 for 10)), ''), -- usdot number
                    nullif(trim(substring(%3$s from 197 for 10)), ''), -- mc/mx number
                    nullif(trim(substring(%3$s from 208 for 1)), ''),  -- usdot/other flag
                    nullif(trim(substring(%3$s from 210 for 10)), ''), -- usdot/other number
                    nullif(trim(substring(%3$s from 221 for 50)), ''), -- carrier name
                    nullif(trim(substring(%3$s from 272 for 1)), '')   -- hit & run driver flag
                )$q2$, db_table, year, quote_nullable(line));
            end if;
        end loop;
    end loop;

    -- Run analyze on temporary tables, which should improve performance on queries on them.
    foreach db_table in array db_tables loop
        execute format($a$ analyze temp_%I_%s$a$, db_table, year);
    end loop;

    raise info '.Clean bad values';
    call nj_clean_data(year);
    
    raise info '.Copy from temp to non-temp tables';
    -- Copy the data from the temp tables into the non-temp tables, by exporting to file and then reimporting. Easiest way to go from text types in temp tables to types in non-temp tables.
    foreach db_table in array db_tables loop
        execute format($q$copy temp_%I_%s to '%s/%I.csv' with (format csv, header)$q$, db_table, year, postgres_data_dir, db_table);
        execute format($q$copy nj_%s.%I from '%s/%I.csv' with (format csv, header, force_null *)$q$, year, db_table, postgres_data_dir, db_table); 
    end loop;
end;
$body$
