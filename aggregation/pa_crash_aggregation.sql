create extension if not exists postgis;
create schema if not exists pa_all;
drop view if exists pa_all.crash;
create view pa_all.crash as

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2005.crash

union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2006.crash

union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2007.crash

union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2008.crash

union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2009.crash
   
union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2010.crash
   
    union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2011.crash
   
union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2012.crash
   
    
union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2013.crash
   
union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2014.crash
   
    
 union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2015.crash
   
    
union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2016.crash
   
    
 union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2017.crash   
   
    union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2018.crash
   
    union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2019.crash
   
    union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2020.crash
   
    union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2021.crash
   
    union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2022.crash
   
    union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2023.crash
   
    union all

select *, ST_SetSRID(
        ST_MakePoint(
            (
                CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS double precision) 
                + CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS double precision) / 3600
            ) * -1,
            (
                CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS double precision) 
                + CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS double precision) / 60 
                + CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS double precision) / 3600
            )
        ),4326
    ) AS shape from pa_2024.crash;




