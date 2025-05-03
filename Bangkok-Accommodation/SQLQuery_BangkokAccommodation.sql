select * ,Area_sq_ft*0.0929 as Area_sq_m 
from Bangkok_Accommodation

--check data where Area_sq_m less than 20
select count(Property_Type) 
from Bangkok_Accommodation
where Area_sq_ft*0.0929 < 20

--create clean view 
CREATE VIEW CleanAccommodation AS
SELECT * FROM Bangkok_Accommodation
WHERE Area_sq_ft * 0.0929 > 20;


--Average of Property
select Property_Type, CAST(ROUND(AVG(Price_THB)/1000000.0, 2) AS FLOAT) AS 'AveragePrice(M)'
from CleanAccommodation
group by Property_type
order by 2 desc

--Average of Location
select Location, CAST(ROUND(AVG(Price_THB)/1000000.0, 2) AS FLOAT) AS 'AveragePrice(M)'
from CleanAccommodation
group by Location
order by 2 desc

--Average of worth property per area
select Location ,cast(avg(Price_THB/(Area_sq_ft*0.0929)) as INT) as 'THB/m^2'
from CleanAccommodation
group by Location
order by 2 desc

