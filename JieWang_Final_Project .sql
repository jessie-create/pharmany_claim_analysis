CREATE SCHEMA `pharmacy`;
-- create schema
 
  CREATE TABLE `pharmacy`.Dimension_filldate (
  `fill_date_id` VARCHAR(45) NOT NULL,
  `fill_date1` VARCHAR(45),
  `fill_date2` VARCHAR(45),
  `fill_date3` VARCHAR(45),
  PRIMARY KEY ( `fill_date_id`));
  -- create fill date dimension table 
  
  CREATE TABLE `pharmacy`.Dim_cost (
 `cost_id` VARCHAR(45) NOT NULL,
  `copay1` INT,
  `copay2` INT,
  `copay3` INT,
  `insurancepaid1` INT,
  `insurancepaid2` INT,
  `insurancepaid3` INT,
  PRIMARY KEY (`cost_id`));
  -- create cost dimension table 
  
  CREATE TABLE `pharmacy`.`Dim_DrugIn` (
  `drug_ndc` INT NOT NULL,
  `drug_name` VARCHAR(45) NOT NULL,
  `drug_form_code` VARCHAR(45) NOT NULL,
  `drug_form_desc`VARCHAR(45) NOT NULL, 
  `drug_brand_generic_code` INT NOT NULL,
  PRIMARY KEY (`drug_ndc`),
  FOREIGN KEY (`drug_brand_generic_code`) REFERENCES Dim_Drugbrand(`drug_brand_generic_code`));
  -- create dim_druginfor taDim_Drugbrandble
  CREATE TABLE `pharmacy`.`Dim_Drugbrand` (
  `drug_brand_generic_code` INT NOT NULL,
  `drug_brand_generic_desc` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`drug_brand_generic_code`));
  -- create drugbrand table
  CREATE TABLE `pharmacy`.`Dim_Member` (
  `member_id` INT NOT NULL,
  `member_first_name` VARCHAR(100) NOT NULL,
  `member_last_name` VARCHAR(100) NOT NULL,
  `member_birth_date` VARCHAR(100) NOT NULL,
  `member_age` INT NOT NULL,
  `member_gender` varchar(1) NOT NULL,
  PRIMARY KEY (`memeber_id`));
-- create member dimension table
CREATE TABLE `pharmacy`.FactTable (
  `member_id` INT  NOT NULL,
  `drug_ndc` INT NOT NULL,
  `fill_date_id` VARCHAR(45) ,
  `cost_id` VARCHAR(45),
  FOREIGN KEY (`member_id`) REFERENCES Dim_Member(`member_id`),
  FOREIGN KEY (`drug_ndc`) REFERENCES Dim_DrugIn (`drug_ndc`),
  FOREIGN KEY (`fill_date_id`) REFERENCES Dimension_filldate (`fill_date_id`),
  FOREIGN KEY (`cost_id`) REFERENCES Dim_cost(`cost_id`));
      -- create main fact table 
SELECT COUNT(FactTable.drug_ndc) ,Dim_DrugIn.drug_name FROM FactTable JOIN  Dim_DrugIn ON FactTable .drug_ndc = Dim_DrugIn.drug_ndc
GROUP BY Dim_DrugIn.drug_name;
-- identifies the number of prescriptions grouped by drug name

SELECT copay2, copay3, insurancepaid2,insurancepaid3 FROM Dim_cost;
UPDATE Dim_cost
SET  copay2 = COALESCE(copay2, 0 ), copay3 = COALESCE(copay3, 0 ),insurancepaid2 = COALESCE(insurancepaid2, 0 ),insurancepaid3 = COALESCE(insurancepaid3, 0 );
-- update null as 0

CREATE Table `pharmacy`.table1(
SELECT FactTable.drug_ndc,FactTable.member_id,Dim_Member.member_age,
ROW_NUMBER () OVER (ORDER BY FactTable.drug_ndc) AS CountPrescription,
ROW_NUMBER () OVER (PARTITION BY Dim_Member.member_id) AS CountMember,
SUM(Dim_cost.copay1+Dim_cost.copay2+Dim_cost.copay3) AS TotalCopay,
SUM(Dim_cost.insurancepaid1 + Dim_cost.insurancepaid2 + Dim_cost.insurancepaid3 ) AS TotalInsurancePaid
FROM FactTable JOIN  Dim_Member ON FactTable.member_id = Dim_Member.member_id JOIN Dim_cost ON FactTable.cost_id = Dim_cost.cost_id
GROUP BY Dim_Member.member_age, Dim_Member.member_id,FactTable.drug_ndc
ORDER BY CountPrescription);
select 
CASE
	   WHEN member_age > 65 THEN   'age > 65'
	   WHEN member_age < 65 THEN ' age < 65 '
END  as AgeGroup,drug_ndc,member_id,member_age,CountPrescription,CountMember,TotalCopay,TotalInsurancePaid 
from  table1
order by AgeGroup;
-- counts total prescriptions, counts unique (i.e. distinct) members, sums copay $$, and sums insurance paid $$, for members grouped as either ‘age 65+’ or ’ < 65


UPDATE Dimension_filldate
SET  fill_date1 = STR_TO_DATE(fill_date1, '%m/%d/%Y' );
-- string to date of fill_date1 

select fill_date_id , fill_date1, str_to_date(fill_date2, '%m/%d/%Y') as fill_date2, str_to_date(fill_date3,'%m/%d/%Y') as fill_date3,
row_number() over (partition by fill_date_id ) as flag
from Dimension_filldate;

create table A(
select fill_date_id , fill_date1, str_to_date(fill_date2, '%m/%d/%Y') as fill_date2, str_to_date(fill_date3,'%m/%d/%Y') as fill_date3,
row_number() over (partition by fill_date_id ) as flag
from Dimension_filldate);

select 
case   
 when fill_date3 > filldate2 then 'fill_date3'
  else fill_date2
 when fill_date2 > filldate1 then 'fill_date2'
   else fill_date1
   end as fill_date 
   from   Dimension_filldate;     




  




