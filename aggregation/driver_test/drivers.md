# NJ Crash Data: Driver Validation

## Tables  

**all_crash:** all crash events  
**all_person:** all people involved in crashes (combination of Occupant and Pedestrian table)  
**all_driver:** all motor vehicle drivers involved in crashes  
**all_vehicle:** all motor vehicles involved in crashes  

## Counts 

**all_person**  

```
select count(*) from nj.all_person where position_in_veh = '01'
```  

n = 425804 

**all_driver**  

```  
select count(*) from nj.all_driver; 
```  

n = 468660

There are 42856 more drivers in the **all_driver** table 

## Validation  

### Crash records missing from all_person table  

```  
with crash as (select casenumber from nj.all_crash), 
person as (select casenumber, veh_num from nj.all_person), 
driver as (select casenumber, veh_num from nj.all_driver)

select count (b.*) from (select a.* from (select c.casenumber, p.casenumber as person_casenumber, p.veh_num from crash c 
left join person p 
on c.casenumber = p.casenumber ) as a
left join driver d 
on a.casenumber = d.casenumber) as b
where b.person_casenumber is null; 
```  
n = 6563  

There are 6563 crash vehicles/drivers that have no corresponding records in the Person table  

### Vehicles missing drivers  

```  
select 

    sum(a.vehicle_count) as total_vehicles,   
    sum(a.driver_count) as total_drivers from  
        (select 
            casenumber,  
            count(distinct(casenumber, veh_num)) as  vehicle_count,   
            count(distinct(casenumber, veh_num)) filter (where position_in_veh = '01') as driver_count   
        from nj.all_person group by casenumber) as a; 

```  
**total_vehicles:** 439919  
**total_drivers:** 425455  

There are 14464 vehicles in the all_person table missing a driver  

### Vehicle count discrepancy  

```  
select count(distinct(casenumber, veh_num)) from nj.all_driver; 

select count(distinct(casenumber, veh_num)) from nj.all_person; 
```  
**all_driver:** 468660  
**all_person:** 439919

There are 28741 fewer vehicles in the **all_person** table than there are in the **all_driver** table
