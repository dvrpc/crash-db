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
                execute format($q$copy temp_crash_%s_one_column from '%s/nj/%s%sAccidents-utf8.txt' with (format text)$q$, year, user_data_dir, county, year);
            end loop;
        else
            foreach county in array counties loop
                execute format($q$copy temp_%s_%s_one_column from '%s/nj/%s%s%ss-utf8.txt' with (format text)$q$, db_table, year, user_data_dir, county, year, initcap(db_table));
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
    -- call nj_alter_temp_domains(year);

    raise info '.Parse columns from spec & insert into second set of temporary tables';
    foreach db_table in array db_tables loop
        for line in execute format($q1$select one_column from temp_%s_%s_one_column$q1$, db_table, year) loop
            if db_table = 'crash' then
                execute format($q2$insert into temp_%1$s_%2$s values (
                    trim(substring(%3$s from 1 for 4)),    -- year
                    trim(substring(%3$s from 5 for 2)),    -- county code
                    trim(substring(%3$s from 7 for 2)),    -- municipality code
                    trim(substring(%3$s from 9 for 23)),   -- dept case num
                    trim(substring(%3$s from 33 for 12)),  -- county name
                    trim(substring(%3$s from 46 for 24)),  -- municipality name
                    trim(substring(%3$s from 71 for 10)),  -- crash date
                    trim(substring(%3$s from 82 for 2)),   -- crash day of week
                    trim(substring(%3$s from 85 for 4)),   -- crash time
                    trim(substring(%3$s from 90 for 2)),   -- police dept code
                    trim(substring(%3$s from 93 for 25)),  -- police dept
                    trim(substring(%3$s from 119 for 15)), -- police station
                    trim(substring(%3$s from 135 for 2)),  -- total killed
                    trim(substring(%3$s from 138 for 2)),  -- total injured
                    trim(substring(%3$s from 141 for 2)),  -- pedestrians killed
                    trim(substring(%3$s from 144 for 2)),  -- pedestrians injured
                    trim(substring(%3$s from 147 for 1)),  -- severity
                    trim(substring(%3$s from 149 for 1)),  -- intersection
                    trim(substring(%3$s from 151 for 1)),  -- alcohol involved
                    trim(substring(%3$s from 153 for 1)),  -- hazmat involved
                    trim(substring(%3$s from 155 for 2)),  -- crash type code
                    trim(substring(%3$s from 158 for 2)),  -- total vehs involved
                    trim(substring(%3$s from 161 for 50)), -- crash location
                    trim(substring(%3$s from 212 for 1)),  -- location direction
                    trim(substring(%3$s from 214 for 4)),  -- route
                    trim(substring(%3$s from 219 for 1)),  -- route suffix
                    trim(substring(%3$s from 221 for 16)), -- sri
                    trim(substring(%3$s from 238 for 7)),  -- milepost
                    trim(substring(%3$s from 246 for 2)),  -- road system
                    trim(substring(%3$s from 249 for 2)),  -- road character
                    trim(substring(%3$s from 252 for 2)),  -- road horizontal alignment
                    trim(substring(%3$s from 255 for 2)),  -- road grade
                    trim(substring(%3$s from 258 for 2)),  -- road surface type
                    trim(substring(%3$s from 261 for 2)),  -- surface condition
                    trim(substring(%3$s from 264 for 2)),  -- light condition
                    trim(substring(%3$s from 267 for 2)),  -- environmental condition
                    trim(substring(%3$s from 270 for 2)),  -- road divided by
                    trim(substring(%3$s from 273 for 2)),  -- temp traffic control zone
                    trim(substring(%3$s from 276 for 4)),  -- distance to cross street
                    trim(substring(%3$s from 281 for 2)),  -- unit of measurement
                    trim(substring(%3$s from 284 for 1)),  -- direction from cross street
                    trim(substring(%3$s from 286 for 35)), -- cross street name
                    trim(substring(%3$s from 322 for 1)),  -- is rampe
                    trim(substring(%3$s from 324 for 25)), -- ramp to/from route name
                    trim(substring(%3$s from 350 for 2)),  -- ramp to/from route direction
                    trim(substring(%3$s from 353 for 2)),  -- posted speed
                    trim(substring(%3$s from 356 for 2)),  -- posted speed at cross street
                    trim(substring(%3$s from 359 for 2)),  -- first harmful event
                    trim(substring(%3$s from 362 for 9)),  -- latitude
                    trim(substring(%3$s from 372 for 9)),  -- longitude
                    trim(substring(%3$s from 382 for 1)),  -- cell phone in use flag
                    trim(substring(%3$s from 384 for 80)), -- other property damage
                    trim(substring(%3$s from 465 for 5))   -- reporting badge no
                )$q2$, db_table, year, quote_nullable(line));
            elseif db_table = 'driver' then
                execute format($q2$insert into temp_%1$s_%2$s values (
                    trim(substring(%3$s from 1 for 4)),    -- year
                    trim(substring(%3$s from 5 for 2)),    -- county code
                    trim(substring(%3$s from 7 for 2)),    -- municipality code
                    trim(substring(%3$s from 9 for 23)),   -- dept case no
                    trim(substring(%3$s from 33 for 2)),   -- veh num
                    trim(substring(%3$s from 36 for 25)),  -- driver city
                    trim(substring(%3$s from 62 for 2)),   -- driver state
                    trim(substring(%3$s from 65 for 5)),   -- driver zip code
                    trim(substring(%3$s from 71 for 2)),   -- driver license state
                    trim(substring(%3$s from 75 for 1)),   -- driver sex
                    trim(substring(%3$s from 77 for 1)),   -- alcohol test given
                    trim(substring(%3$s from 79 for 2)),   -- alcohol test type
                    trim(substring(%3$s from 82 for 3)),   -- alcohol test results
                    trim(substring(%3$s from 86 for 30)),  -- charge 1
                    trim(substring(%3$s from 117 for 30)), -- summons 1
                    trim(substring(%3$s from 148 for 30)), -- charge 2
                    trim(substring(%3$s from 179 for 30)), -- summons 2 
                    trim(substring(%3$s from 210 for 30)), -- charge 3
                    trim(substring(%3$s from 241 for 30)), -- summons 3
                    trim(substring(%3$s from 272 for 30)), -- charge 4
                    trim(substring(%3$s from 303 for 30)), -- summons 4
                    trim(substring(%3$s from 334 for 1)),  -- multi charge flag
                    trim(substring(%3$s from 336 for 2)),  -- driver physical status 1
                    trim(substring(%3$s from 339 for 2))   -- driver physical status 2
                )$q2$, db_table, year, quote_nullable(line));
            elseif db_table = 'occupant' then
                execute format($q2$insert into temp_%1$s_%2$s values (
                    trim(substring(%3$s from 1 for 4)),    -- year
                    trim(substring(%3$s from 5 for 2)),    -- county code
                    trim(substring(%3$s from 7 for 2)),    -- municipality code
                    trim(substring(%3$s from 9 for 23)),   -- dept case no
                    trim(substring(%3$s from 33 for 2)),   -- veh num
                    trim(substring(%3$s from 36 for 2)),   -- occupant number
                    trim(substring(%3$s from 39 for 2)),   -- physical condition
                    trim(substring(%3$s from 42 for 2)),   -- position in/on veh
                    trim(substring(%3$s from 45 for 2)),   -- ejection code
                    trim(substring(%3$s from 48 for 3)),   -- age
                    trim(substring(%3$s from 52 for 1)),   -- sex
                    trim(substring(%3$s from 54 for 2)),   -- location of most severe injury
                    trim(substring(%3$s from 57 for 2)),   -- type of most severe injury
                    trim(substring(%3$s from 60 for 2)),   -- refused medical attn 
                    trim(substring(%3$s from 63 for 2)),   -- safety equip available
                    trim(substring(%3$s from 66 for 2)),   -- safety equip used
                    trim(substring(%3$s from 69 for 2)),   -- airbag deployment
                    trim(substring(%3$s from 72 for 4))    -- hospital code
                )$q2$, db_table, year, quote_nullable(line));
            elseif db_table = 'pedestrian' then
                execute format($q2$insert into temp_%1$s_%2$s values (
                    trim(substring(%3$s from 1 for 4)),     -- year
                    trim(substring(%3$s from 5 for 2)),     -- county code
                    trim(substring(%3$s from 7 for 2)),     -- municipality code
                    trim(substring(%3$s from 9 for 23)),    -- dept case no
                    trim(substring(%3$s from 33 for 2)),    -- pedestrian num
                    trim(substring(%3$s from 36 for 2)),    -- physical condition
                    trim(substring(%3$s from 39 for 25)),   -- address city
                    trim(substring(%3$s from 65 for 2)),    -- address state
                    trim(substring(%3$s from 68 for 5)),    -- address zip
                    trim(substring(%3$s from 75 for 3)),    -- age
                    trim(substring(%3$s from 79 for 1)),    -- sex
                    trim(substring(%3$s from 81 for 1)),    -- alcohol test given
                    trim(substring(%3$s from 83 for 2)),    -- alcohol test type
                    trim(substring(%3$s from 86 for 3)),    -- alcohol test results
                    trim(substring(%3$s from 90 for 30)),   -- charge1
                    trim(substring(%3$s from 121 for 30)),  -- summons1
                    trim(substring(%3$s from 152 for 30)),  -- charge2
                    trim(substring(%3$s from 183 for 30)),  -- summons2
                    trim(substring(%3$s from 214 for 30)),  -- charge3
                    trim(substring(%3$s from 245 for 30)),  -- summons3
                    trim(substring(%3$s from 276 for 30)),  -- charge4
                    trim(substring(%3$s from 307 for 30)),  -- summons4
                    trim(substring(%3$s from 338 for 1)),   -- multi-charge flag
                    trim(substring(%3$s from 340 for 2)),   -- traffic controls
                    trim(substring(%3$s from 343 for 2)),   -- contrib circumstances 1
                    trim(substring(%3$s from 346 for 2)),   -- contrib circumstances 2
                    trim(substring(%3$s from 349 for 2)),   -- direction of travel
                    trim(substring(%3$s from 352 for 2)),   -- pre-crash action
                    trim(substring(%3$s from 355 for 2)),   -- location of most severe injury
                    trim(substring(%3$s from 358 for 2)),   -- type of most severe injury
                    trim(substring(%3$s from 361 for 2)),   -- refused medical attn
                    trim(substring(%3$s from 364 for 2)),   -- safety equipment used
                    trim(substring(%3$s from 367 for 4)),   -- hospital code
                    trim(substring(%3$s from 372 for 2)),   -- physical status 1
                    trim(substring(%3$s from 375 for 2)),   -- physical status 2
                    trim(substring(%3$s from 378 for 1)),   -- is bicyclist?
                    trim(substring(%3$s from 380 for 1))    -- is other?
                )$q2$, db_table, year, quote_nullable(line));
            elseif db_table = 'vehicle' then
                execute format($q2$insert into temp_%1$s_%2$s values (
                    trim(substring(%3$s from 1 for 4)),    -- year
                    trim(substring(%3$s from 5 for 2)),    -- county code
                    trim(substring(%3$s from 7 for 2)),    -- municipality code
                    trim(substring(%3$s from 9 for 23)),   -- dept case no
                    trim(substring(%3$s from 33 for 2)),   -- vehicle number
                    trim(substring(%3$s from 36 for 4)),   -- insurance company code
                    trim(substring(%3$s from 41 for 2)),   -- owner state
                    trim(substring(%3$s from 44 for 30)),  -- make of vehicle
                    trim(substring(%3$s from 75 for 20)),  -- model of vehicle
                    trim(substring(%3$s from 96 for 3)),   -- color of vehicle
                    trim(substring(%3$s from 100 for 4)),  -- year of vehicle
                    trim(substring(%3$s from 105 for 2)),  -- license plate state
                    trim(substring(%3$s from 108 for 1)),  -- vehicle weight rating
                    trim(substring(%3$s from 110 for 1)),  -- towed
                    trim(substring(%3$s from 112 for 2)),  -- removed by
                    trim(substring(%3$s from 115 for 1)),  -- driven/left/towed
                    trim(substring(%3$s from 117 for 2)),  -- initial impact location
                    trim(substring(%3$s from 120 for 2)),  -- principal impact location
                    trim(substring(%3$s from 123 for 2)),  -- extent of damage
                    trim(substring(%3$s from 126 for 2)),  -- traffic controls present
                    trim(substring(%3$s from 129 for 2)),  -- vehicle type
                    trim(substring(%3$s from 132 for 2)),  -- vehicle use
                    trim(substring(%3$s from 135 for 2)),  -- special function veh
                    trim(substring(%3$s from 138 for 2)),  -- cargo body type
                    trim(substring(%3$s from 141 for 2)),  -- contrib circumstance 1
                    trim(substring(%3$s from 144 for 2)),  -- contrib circumstance 2
                    trim(substring(%3$s from 147 for 2)),  -- direction of travel
                    trim(substring(%3$s from 150 for 2)),  -- pre-crash action
                    trim(substring(%3$s from 153 for 2)),  -- first seq of events
                    trim(substring(%3$s from 156 for 2)),  -- second seq of events
                    trim(substring(%3$s from 159 for 2)),  -- third seq of events
                    trim(substring(%3$s from 162 for 2)),  -- fourth seq of events
                    trim(substring(%3$s from 165 for 2)),  -- most harmful event
                    trim(substring(%3$s from 168 for 2)),  -- oversize/overweight permit
                    trim(substring(%3$s from 171 for 1)),  -- hazmat status
                    trim(substring(%3$s from 173 for 1)),  -- hazmat class
                    trim(substring(%3$s from 175 for 10)), -- hazmat placard
                    trim(substring(%3$s from 186 for 10)), -- usdot number
                    trim(substring(%3$s from 197 for 10)), -- mc/mx number
                    trim(substring(%3$s from 208 for 1)),  -- usdot/other flag
                    trim(substring(%3$s from 210 for 10)), -- usdot/other number
                    trim(substring(%3$s from 221 for 50)), -- carrier name
                    trim(substring(%3$s from 272 for 1))   -- hit & run driver flag
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
