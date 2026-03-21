-- Set level of messages displayed.
set client_min_messages = error;

do
$body$
declare
    max_hhmm integer = 2400;

begin

    /* Domains that data should ultimately conform to.

    They must be in a transaction, so that a duplicate error can be ignored.

    If, during cleaning, a domain doesn't conform to one of these, add a new one here and then
    change the field to use that domain in alter_domains.sql.  */
        
    -- NJ explicitly gives range of 0001 to 2400 (p. 18 of 2017 NJ Crash Report Manual)
    -- I had previously assumed PA was 00:00-23:59, but not sure. Allowing up to 2400 for both.
    begin
        execute format($q$create domain text24hhmm text check(value::int <= %s)$q$, max_hhmm);
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

    begin
        create domain text00_23 text check(value::int between 0 and 23);
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

    begin
        create domain text_year text check(value::int >= 1900);
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

    begin
        create domain text_month text check(value::int between 1 and 12);
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text_direction text check(value in ('N', 'E', 'S', 'W'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

    begin
        create domain text_direction_bound text check(value in ('NB', 'EB', 'SB', 'WB'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

    /*
        Temporary domains - used in order to get invalid data into temporary tables', which will
        then be cleaned before going into the non-temp tables.
    */
    begin
        execute format($q$create domain text24hhmm_9999 text check(value::int <= %s or value::int = 9999)$q$, max_hhmm);
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text00_23_99 text check(value::int between 0 and 23 or value::int = 99);
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

    begin
        -- Domain to allow any positive integer through before being cleaned.
        create domain text_as_pos_int text check(value::int >= 0);
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

    -- Domain to allow 00-04 through for dir_of_travel in the NJ pedestrian
    -- and vehicle tables. Since they get changed to cardinal directions during cleaning,
    -- also allow those.
    begin
        create domain text_00_04_direction text check(value in ('00', '01', '02', '03', '04', 'N', 'E', 'S', 'W'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

    -- found '98', '0' '3 ' in 2023 data
    begin
        create domain text_direction1 text check(value in ('00', '01', '02', '03', '04', '0', '0 ', '98', '3 ', '3', 'N', 'E', 'S', 'W'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

    /*
        Boolean domains, using text as the base.
        The first one is the broadest that can be successfully and unambiguously
        converted into boolean (after 9 and U converted to null). In the attempt to validate the
        data in the temporary tables, it should be used first. If the values in a field fail it, the
        ones below, starting from most restrictive to least, should then be used.
    */
    begin
        create domain text019YNTFUspace_as_bool text check(value in ('0', '0.0', '1', '1.0', 'Y', 'N', 'T', 'F', 'U', '9', '9.0', ' '));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text019YNUspace_as_bool text check(value in ('0', '0.0', '1', '1.0', 'Y', 'N', 'U', '9', '9.0', ' '));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text01_as_bool text check(value in ('0', '1'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text012_as_bool text check(value in ('0', '1', '2'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text0129_as_bool text check(value in ('0', '1', '2', '9'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text0129U_as_bool text check(value in ('0', '1', '2', '9', 'U'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text12_as_bool text check(value in ('1', '2'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text129_as_bool text check(value in ('1', '2', '9'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain textYNR_as_bool text check(value in ('Y', 'N', 'R'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain textYNU_as_bool text check(value in ('Y', 'N', 'U'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text_01_02_99_as_bool text check(value in ('01', '02', '99'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text_0_1_01_02_99_as_bool text check(value in ('0', '1', '01', '02', '99'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text_0_1_2_11_as_bool text check(value in ('0', '1', '2', '11'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text_0_1_2_3_11_as_bool text check(value in ('0', '1', '2', '3', '11'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text_0_1_2_3_7_11_as_bool text check(value in ('0', '1', '2', '3', '7', '11'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;

        -- Domains merely for figuring out what values are contained in a field.
    begin
        create domain text029U text check(value in ('0', '2', '9', 'U'));
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
        create domain text2 text check(value = '2');
    exception
        when duplicate_column then
            null;
        when others then
            raise notice '%', SQLSTATE;
    end;
    begin
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
