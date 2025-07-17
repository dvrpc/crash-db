-- Set level of messages displayed.
set client_min_messages = error;

do
$body$
begin

    begin
        -- Domains that data should ultimately conform to.
        create domain text24hhmm text check(value::int <= 2359);
        create domain text00_23 text check(value::int between 0 and 23);
        create domain text_year text check(value::int >= 1900);
        create domain text_month text check(value::int between 1 and 12);
        create domain text_direction text check(value in ('N', 'E', 'S', 'W'));

        /*
            Temporary domains - used in order to get invalid data into temporary tables', which will
            then be cleaned before going into the non-temp tables.
        */
        create domain text24hhmm_9999 text check(value::int <= 2359 or value::int = 9999);
        create domain text00_23_99 text check(value::int between 0 and 23 or value::int = 99);

        -- Domain to allow any positive integer through before being cleaned.
        create domain text_as_pos_int text check(value::int >= 0);

        -- Domain to allow 00-04 through for dir_of_travel in the NJ pedestrian
        -- and vehicle tables. Since they get changed to cardinal directions during cleaning,
        -- also allow those.
        create domain text_00_04_direction text check(value in ('00', '01', '02', '03', '04', 'N', 'E', 'S', 'W'));

        /*
            Boolean domains, using text as the base.
            The first one is the broadest that can be successfully and unambiguously
            converted into boolean (after 9 and U converted to null). In the attempt to validate the
            data in the temporary tables, it should be used first. If the values in a field fail it, the
            ones below, starting from most restrictive to least, should then be used.
        */
        create domain text019YNTFUspace_as_bool text check(value in ('0', '0.0', '1', '1.0', 'Y', 'N', 'T', 'F', 'U', '9', '9.0', ' '));
        create domain text019YNUspace_as_bool text check(value in ('0', '0.0', '1', '1.0', 'Y', 'N', 'U', '9', '9.0', ' '));
        create domain text01_as_bool text check(value in ('0', '1'));
        create domain text012_as_bool text check(value in ('0', '1', '2'));
        create domain text0129_as_bool text check(value in ('0', '1', '2', '9'));
        create domain text0129U_as_bool text check(value in ('0', '1', '2', '9', 'U'));
        create domain text12_as_bool text check(value in ('1', '2'));
        create domain text129_as_bool text check(value in ('1', '2', '9'));
        create domain textYNR_as_bool text check(value in ('Y', 'N', 'R'));
        create domain textYNU_as_bool text check(value in ('Y', 'N', 'U'));
        create domain text_01_02_99_as_bool text check(value in ('01', '02', '99'));
        create domain text_0_1_01_02_99_as_bool text check(value in ('0', '1', '01', '02', '99'));
        create domain text_0_1_2_11_as_bool text check(value in ('0', '1', '2', '11'));
        create domain text_0_1_2_3_11_as_bool text check(value in ('0', '1', '2', '3', '11'));
        create domain text_0_1_2_3_7_11_as_bool text check(value in ('0', '1', '2', '3', '7', '11'));

        -- Domains merely for figuring out what values are contained in a field.
        create domain text029U text check(value in ('0', '2', '9', 'U'));
        create domain text2 text check(value = '2');
        create domain text02 text check(value in ('0', '2'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

end;
$body$
language plpgsql;
