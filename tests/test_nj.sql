-- Testing against NJ's published crash statistics at
-- <https://dot.nj.gov/transportation/refdata/accident/crash_statistics.shtm>

begin;
select plan(64);

-- select is(count(*), '11939') from nj_2004.crash where ncic_code like '03%%' and road_system != '09';
-- select is(count(*), '11422') from nj_2005.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '11196', '2006 Burlington total crashes') from nj_2006.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '11436', '2007 Burlington total crashes') from nj_2007.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '10760', '2008 Burlington total crashes') from nj_2008.crash where ncic_code like '03%%' and road_system != '09';
-- select is(count(*), '11038') from nj_2009.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '11339', '2010 Burlington total crashes') from nj_2010.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '10833', '2011 Burlington total crashes') from nj_2011.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '10449', '2012 Burlington total crashes') from nj_2012.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '11039', '2013 Burlington total crashes') from nj_2013.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '11413', '2014 Burlington total crashes') from nj_2014.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '11797', '2015 Burlington total crashes') from nj_2015.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '12124', '2016 Burlington total crashes') from nj_2016.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '11822', '2017 Burlington total crashes') from nj_2017.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '12238', '2018 Burlington total crashes') from nj_2018.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '11172', '2019 Burlington total crashes') from nj_2019.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '8888', '2020 Burlington total crashes') from nj_2020.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '9299', '2021 Burlington total crashes') from nj_2021.crash where ncic_code like '03%%' and road_system != '09';
select is(count(*), '10196', '2022 Burlington total crashes') from nj_2022.crash where ncic_code like '03%%' and road_system != '09';
-- select is(count(*), '15706')  from nj_2004.crash where ncic_code like '04%%' and road_system != '09';
-- select is(count(*), '15264')  from nj_2005.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '14646')  from nj_2006.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '15564')  from nj_2007.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '14941')  from nj_2008.crash where ncic_code like '04%%' and road_system != '09';
-- select is(count(*), '15081')  from nj_2009.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '14213')  from nj_2010.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '13023')  from nj_2011.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '12727')  from nj_2012.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '13324')  from nj_2013.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '12801')  from nj_2014.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '12545')  from nj_2015.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '13545')  from nj_2016.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '15176')  from nj_2017.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '15755')  from nj_2018.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '14950')  from nj_2019.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '11002')  from nj_2020.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '12679')  from nj_2021.crash where ncic_code like '04%%' and road_system != '09';
select is(count(*), '13625')  from nj_2022.crash where ncic_code like '04%%' and road_system != '09';
-- select is(count(*), '6890')  from nj_2004.crash where ncic_code like '08%%' and road_system != '09';
-- select is(count(*), '7082')  from nj_2005.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '6540')  from nj_2006.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '6751')  from nj_2007.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '6778')  from nj_2008.crash where ncic_code like '08%%' and road_system != '09';
-- select is(count(*), '7014')  from nj_2009.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '6803')  from nj_2010.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '6511')  from nj_2011.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '5807')  from nj_2012.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '5591')  from nj_2013.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '5740')  from nj_2014.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '7032')  from nj_2015.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '7587')  from nj_2016.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '7515')  from nj_2017.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '7713')  from nj_2018.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '7121')  from nj_2019.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '6022')  from nj_2020.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '6880')  from nj_2021.crash where ncic_code like '08%%' and road_system != '09';
select is(count(*), '6979')  from nj_2022.crash where ncic_code like '08%%' and road_system != '09';
-- select is(count(*), '13361') from nj_2004.crash where ncic_code like '11%%' and road_system != '09';
-- select is(count(*), '12943') from nj_2005.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '12040') from nj_2006.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '12169') from nj_2007.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '11540') from nj_2008.crash where ncic_code like '11%%' and road_system != '09';
-- select is(count(*), '11825') from nj_2009.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '11772') from nj_2010.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '12039') from nj_2011.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '10931') from nj_2012.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '11703') from nj_2013.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '11041') from nj_2014.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '12059') from nj_2015.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '12262') from nj_2016.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '10337') from nj_2017.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '10473') from nj_2018.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '11576') from nj_2019.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '7495') from nj_2020.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '8287') from nj_2021.crash where ncic_code like '11%%' and road_system != '09';
select is(count(*), '9379') from nj_2022.crash where ncic_code like '11%%' and road_system != '09';


-- select is(count(*), '11196', 'correct amount of crashes in NJ Burlington 2006')
--     from nj_2006.crash where ncic_code like '03%%' and road_system != '09';
-- select is(count(*), '14646', 'correct amount of crashes in NJ Camden 2006')
--     from nj_2006.crash where ncic_code like '04%%' and road_system != '09';

select * from finish();
rollback;
