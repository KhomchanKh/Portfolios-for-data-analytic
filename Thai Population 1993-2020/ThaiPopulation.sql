--check null or zero in column 4-9 and column 14

select RCODE_CODE,count(RCODE_CODE) as Count_Rcode_Code_Zero
from stat_c
group by RCODE_CODE

select count(case when RCODE_desc is null then 1 end) as Count_Rcode_Desc_Null
from stat_c

select CCAATT_CODE,count(CCAATT_CODE) as Count_CCAATT_Code_Zero
from stat_c
group by CCAATT_CODE

select count(case when CCAATT_desc is null then 1 end) as Count_CCAATT_Desc_Null
from stat_c

select CCAATTMM_CODE,count(CCAATTMM_CODE) as Count_CCAATTMM_Code_Zero
from stat_c
group by CCAATTMM_CODE

select count(case when CCAATTMM_desc is null then 1 end) as Count_CCAATTMM_Desc_Null
from stat_c

select count(case when column14 is null then 1 end) as Count_column14_Null
from stat_c


--Create new table that is removed the columns and insert data

IF OBJECT_ID('ThaiPop93to20', 'U') IS NULL
create table ThaiPop93to20(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	YYMM nvarchar(255),
	CC_CODE nvarchar(255),
	CC_DESC nvarchar(255),
	MALE int,
	FEMALE int,
	TOTAL int,
	HOUSE int);

insert into ThaiPop93to20(YYMM ,CC_CODE,CC_DESC,MALE,FEMALE,TOTAL,HOUSE)
select YYMM ,CC_CODE,CC_DESC,MALE,FEMALE,TOTAL,HOUSE 
from stat_c

--Transform Date

Alter table ThaiPop93to20
add NewYear nvarchar(255)

update ThaiPop93to20
set NewYear = '25'+SUBSTRING(YYMM,1,2)


Alter table ThaiPop93to20
drop column YYMM

update ThaiPop93to20
set NewYear = CAST(NewYear as INT) - 543


--Check Corrective Total
select case
			when MAlE+FEMALE = TOTAL THEN 'Correct'
			else 'Incorrect'
	   end as CheckTotal,count(*)
from ThaiPop93to20
group by 
	case
			when MAlE+FEMALE = TOTAL THEN 'Correct'
			else 'Incorrect'
	end


--ADD column Region that depend on PostCode
Alter table ThaiPop93to20
add Region nvarchar(255)

update ThaiPop93to20
set Region = (case 
					when CC_CODE like '1_' then 'ภาคกลาง'
					when CC_CODE like '2_' then 'ภาคตะวันออก'
					when CC_CODE like '3_' then 'ภาคตะวันออกเฉียงเหนือ'
					when CC_CODE like '4_' then 'ภาคตะวันออกเฉียงเหนือ'
					when CC_CODE like '5_' then 'ภาคเหนือ'
					when CC_CODE like '6_' then 'ภาคเหนือ'
					when CC_CODE like '7_' then 'ภาคตะวันตก'
					when CC_CODE like '8_' then 'ภาคใต้'
					when CC_CODE like '9_' then 'ภาคใต้'
					Else CC_DESC
					End)


--Remove 'จังหวัด' on CC_DESC
select SUBSTRING(CC_DESC,CHARINDEX('ด',CC_DESC)+1,LEN(CC_DESC)) from ThaiPop93to20

update ThaiPop93to20
set CC_DESC = SUBSTRING(CC_DESC,CHARINDEX('ด',CC_DESC)+1,LEN(CC_DESC))



--Add Columns Population growth and Population growth rate
with
CTE_POP as
(select pop1.CC_CODE,
		pop1.CC_DESC,
		pop1.Region,pop1.NewYear as NewYear,
		pop1.TOTAL as NewPop,
		pop2.NewYear as OldYear,
		pop2.TOTAL as OldPop 
		from ThaiPop93to20 as pop1
		join ThaiPop93to20 as pop2
on pop1.CC_DESC = pop2.CC_DESC and pop1.NewYear = pop2.NewYear + 1)

--Check Population growth and Population growth rate before add in table
select * ,
		NewPop-OldPop as [Population growth],
		cast((NewPop-OldPop)*1.0/nullif(OldPop,0) as float) as [Population growth rate] 
from CTE_POP

Alter table ThaiPop93to20
add [Population growth] int

Alter table ThaiPop93to20
add [Population growth rate] float

--Add data of Population growth,Population growth in table
update T
set [Population growth] = NewPop-OldPop,
	[Population growth rate] = cast((NewPop-OldPop)*1.0/nullif(OldPop,0) as float)
	from ThaiPop93to20 as T
	join CTE_POP as C 
	on T.CC_DESC = C.CC_DESC and T.NewYear = C.NewYear


--create view which don't have 'ทั่วประเทศ'

create view ThaiPop_OnlyProvinces as
select * from ThaiPop93to20
where Region <> 'ทั่วประเทศ'

--create view which have only 'ทั่วประเทศ'
create view ThaiPop_OnlyWholeCountry as
select * from ThaiPop93to20
where Region = 'ทั่วประเทศ'
