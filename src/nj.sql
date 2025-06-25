-- Import NJ data.
do
$import$
declare
    -- can put a single year here (i.e. generate_series(2020, 2020)) to go year-by-year 
    years int[] := ARRAY(SELECT * FROM generate_series(2025, 2025));
    year int;
begin
    raise info 'In NJ script';
end;
$import$
language plpgsql;

-- vacuum analyze
