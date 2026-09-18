select count(*) from diabetic_data_raw;
select * from diabetic_data_raw
limit 10;

-- step 1
alter table diabetic_data_raw
modify diag_1 VARCHAR(10); 
-- convert diag_2 from double to string
-- then turn the safe updates off and perform the updates
set SQL_SAFE_UPDATES=0;
update diabetic_data_raw
set weight=nullif(weight,'?'),
	race=nullif(race,'?'),
    payer_code=nullif(payer_code,'?'),
    medical_specialty=nullif(medical_specialty,'?'),
    diag_1=nullif(diag_1,'?'),
    diag_2=nullif(diag_2,'?'),
    diag_3=nullif(diag_3,'?');
-- aft update turn the safe on
-- optional = set SQL_SAFE_UPDATES=0;

select round(sum(weight is null)/count(*) * 100,1) as pct_missing_wt,
round(sum(payer_code is null)/count(*) * 100, 1) as pct_missing_pc,
round(sum(medical_specialty is null)/count(*) * 100, 1) as pct_missing_ms,
round(sum(race is null)/count(*) * 100, 1) as pct_missing_race
from diabetic_data_raw;
-- analysis the % of missing data, if large amt of data is missing then the column is not really reliable and do not use it

-- step 2 dealing with dup data
select patient_nbr, count(*) as encounter_num from diabetic_data_raw
group by patient_nbr
having count(*)>1
order by encounter_num desc 
limit 10;

create table diabetic_data_dedup as 
select t.* from diabetic_data_raw as t 
inner join (select patient_nbr, min(encounter_id) as first_encounter from diabetic_data_raw
group by patient_nbr) first_enc
on t.patient_nbr = first_enc.patient_nbr and t.encounter_id=  first_enc.first_encounter;

select count(*) from diabetic_data_dedup;

-- step 3 moving into deeper analysis/cleaning

select discharge_disposition_id, count(*) as encounter_count 
from diabetic_data_raw
group by discharge_disposition_id
order by encounter_count desc;

select * from ids_mapping_raw
where description like '%hospice%' or description like '%expired%' or description like '%deceased%';
-- ensure to use description like for every word, only then it acts as condition to find the word.
-- now we need to remove all the admission types as obtained from above select ( as they cannot have another encounter entry)
delete from diabetic_data_dedup
where discharge_disposition_id in (11,13,14,19,20,21,26);

-- step 4 
SELECT * FROM ids_mapping_raw;

CREATE TABLE discharge_disposition_map (
	discharge_disposition_id INT, 
    description VARCHAR(150)
);

CREATE TABLE admission_source_map (
	admission_source_id INT, 
    description VARCHAR(150)
);
describe admission_source_map;
-- here 2 tables are added as they were not read from the csv file, we need to add the data manually

INSERT INTO discharge_disposition_map (discharge_disposition_id, description) VALUES
(1, 'Discharged to home'),
(2, 'Discharged/transferred to another short term hospital'),
(3, 'Discharged/transferred to SNF'),
(4, 'Discharged/transferred to ICF'),
(5, 'Discharged/transferred to another type of inpatient care institution'),
(6, 'Discharged/transferred to home with home health service'),
(7, 'Left AMA'),
(8, 'Discharged/transferred to home under care of Home IV provider'),
(9, 'Admitted as an inpatient to this hospital'),
(10, 'Neonate discharged to another hospital for neonatal aftercare'),
(11, 'Expired'),
(12, 'Still patient or expected to return for outpatient services'),
(13, 'Hospice / home'),
(14, 'Hospice / medical facility'),
(15, 'Discharged/transferred within this institution to Medicare approved swing bed'),
(16, 'Discharged/transferred/referred another institution for outpatient services'),
(17, 'Discharged/transferred/referred to this institution for outpatient services'),
(18, 'NULL'),
(19, 'Expired at home. Medicaid only, hospice.'),
(20, 'Expired in a medical facility. Medicaid only, hospice.'),
(21, 'Expired, place unknown. Medicaid only, hospice.'),
(22, 'Discharged/transferred to another rehab fac including rehab units of a hospital.'),
(23, 'Discharged/transferred to a long term care hospital.'),
(24, 'Discharged/transferred to a nursing facility certified under Medicaid but not certified under Medicare.'),
(25, 'Not Mapped'),
(26, 'Unknown/Invalid'),
(27, 'Discharged/transferred to a federal health care facility.'),
(28, 'Discharged/transferred/referred to a psychiatric hospital of psychiatric distinct part unit of a hospital'),
(29, 'Discharged/transferred to a Critical Access Hospital (CAH).'),
(30, 'Discharged/transferred to another Type of Health Care Institution not Defined Elsewhere');
    
INSERT INTO admission_source_map (admission_source_id, description) VALUES
(1, 'Physician Referral'),
(2, 'Clinic Referral'),
(3, 'HMO Referral'),
(4, 'Transfer from a hospital'),
(5, 'Transfer from a Skilled Nursing Facility (SNF)'),
(6, 'Transfer from another health care facility'),
(7, 'Emergency Room'),
(8, 'Court/Law Enforcement'),
(9, 'Not Available'),
(10, 'Transfer from critial access hospital'),
(11, 'Normal Delivery'),
(12, 'Premature Delivery'),
(13, 'Sick Baby'),
(14, 'Extramural Birth'),
(15, 'Not Available'),
(17, 'NULL'),
(18, 'Transfer From Another Home Health Agency'),
(19, 'Readmission to Same Home Health Agency'),
(20, 'Not Mapped'),
(21, 'Unknown/Invalid'),
(22, 'Transfer from hospital inpt/same fac reslt in a sep claim'),
(23, 'Born inside this hospital'),
(24, 'Born outside this hospital'),
(25, 'Transfer from Ambulatory Surgery Center'),
(26, 'Transfer from Hospice'); 

select * from discharge_disposition_map;
select * from admission_source_map;

-- step 5 
-- creating a new column for age,for better anlysis 
select * from diabetic_data_dedup
limit 20;
alter table diabetic_data_dedup add column age_midpoint int;
update diabetic_data_dedup
set age_midpoint = case
	when age = '[0-10)' then 5
	WHEN age = '[10-20)'  THEN 15
    WHEN age = '[20-30)'  THEN 25
    WHEN age = '[30-40)'  THEN 35
    WHEN age = '[40-50)'  THEN 45
    WHEN age = '[50-60)'  THEN 55
    WHEN age = '[60-70)'  THEN 65
    WHEN age = '[70-80)'  THEN 75
    WHEN age = '[80-90)'  THEN 85
    WHEN age = '[90-100)' THEN 95
END;

-- exploratory analysis
-- finding the readmission encounters based on diff categories
select readmitted, count(*) as encounter_count, 
round(count(*)/(select count(*) from diabetic_data_dedup) *100,1) as pct_of_readmit
from diabetic_data_dedup
group by readmitted
order by encounter_count desc;
-- do the same with age columns
select age,age_midpoint, count(*) as total_encounter_count,
sum(readmitted='<30') as readmitted_bel_30,
round(sum(readmitted='<30')/count(*)*100,1) as pct_of_under30
from diabetic_data_dedup
group by age,age_midpoint
order by age_midpoint;
-- now get this data to analyze the reason(admission_type)
select m.description as admission_type, count(*) as total_encounters, 
round(sum(readmitted='<30')/count(*)*100,1) as pct_of_under30
from diabetic_data_dedup d 
join ids_mapping_raw m 
on m.admission_type_id=d.admission_type_id
group by m.description
order by pct_of_under30 desc;

-- adv techniques
with patient_risk_base as (
SELECT
		encounter_id, 
        patient_nbr, 
        age_midpoint, 
        time_in_hospital, 
        num_medications, 
        num_lab_procedures, 
        number_diagnoses, 
        number_inpatient, 
        number_emergency, 
        number_outpatient, 
        diag_1, 
        readmitted,
        case when readmitted='<30' then 1 else 0 end as is_readmitted_30
	from diabetic_data_dedup)
    select * from patient_risk_base
    limit 20;
    
with patient_risk_base as (
select encounter_id,age_midpoint, num_medications,readmitted,
case when readmitted='<30' then 1 else 0 end as is_readmitted_30
from diabetic_data_dedup)
select encounter_id,age_midpoint,num_medications,readmitted,
rank () over(partition by age_midpoint order by num_medications desc) as med_rank_groups
from patient_risk_base
order by age_midpoint,med_rank_groups;
-- the above query is to is see the people's rank based on age groups and the amount of medication they take, in desc order

with patient_risk_base as (
select encounter_id, number_inpatient,readmitted,
case when readmitted='<30' then 1 else 0 end as is_readmitted_30
from diabetic_data_dedup)
select encounter_id, number_inpatient,
ntile(4) over (order by number_inpatient desc) as risk_quartile
from patient_risk_base;
-- ntile() is a window function that divides the data into the no. of quartiles as mentioned in the brackets
-- here 1 means higher risk patients and 4 means lower risk patients

select encounter_id,num_medications,
case when num_medications<=10 then 'Low' 
	when num_medications between 11 and 20 then 'Medium'
    else 'High' end as medication_burden,
case when number_diagnoses<=5 then 'Low' 
	when number_diagnoses between 6 and 9 then 'Medium'
    else 'High' end as diagnosis_complexity
from diabetic_data_dedup;
-- this query simplifies the importance of patients acc to their level of priority

-- as this is a vast hospital data, below thing is done to catagorize the data accordingly(from codes to strings)
-- diag_1 notes
-- 390–459: Diseases of the circulatory system
-- 460–519: Diseases of the respiratory system
-- 520–579: Diseases of the digestive system
-- 580–629: Diseases of the genitourinary system
-- 800–999: Injury and poisoning

WITH diag_categorized AS (
	SELECT
		encounter_id, 
        readmitted, 
        CASE
			WHEN diag_1 LIKE '250%' THEN 'Diabetes'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 390 AND 459 THEN 'CIRCULATORY'
			WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 460 AND 519 THEN 'Respiratory'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 520 AND 579 THEN 'Digestive'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 580 AND 629 THEN 'Genitourinary'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 800 AND 999 THEN 'Injury'
		ELSE 'Other'
	END AS diagnosis_category, 
    CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END AS is_readmitted_30
	FROM diabetic_data_dedup
    WHERE diag_1 IS NOT NULL
)
select diagnosis_category, count(*) as total_encounters,
round(avg(is_readmitted_30)*100,1) as readmission_rate_pct
from diag_categorized
group by diagnosis_category
having avg(is_readmitted_30)>(select avg(is_readmitted_30) from diag_categorized)
order by readmission_rate_pct desc;
-- this above query gets the diag_categories with highest readmissions

-- last part
-- Finding 1) Top diagnosis categories driving readmission
-- this query is given as above 
-- Finding 2) Does a medication change at discharge affect readmission?
-- necessary to know this to understand the affects of the medication on the patient, imp for the medical team
select `change`, count(*) as total_encounters,
round(sum(readmitted='<30')/count(*) * 100,1) from diabetic_data_dedup
group by `change`;
-- here backticks are used as the word change in sql is a keyword

-- Finding 3) Discharge disposition impact 
-- checking where the patient goes aft discharge, how likely the person would be readmitted
select m.description as discharge_disposition, count(*) as total_encounters,
round(sum(d.readmitted='<30')/count(*) * 100,1) as readmission_rate_pct 
from diabetic_data_dedup d
join discharge_disposition_map m
on d.discharge_disposition_id = m.discharge_disposition_id
group by m.description
having count(*)>100
order by readmission_rate_pct desc;

-- Finding 4) A1C testing and readmission
-- basically A1C indicates a person's average blood glucose level over roughly the past 2–3 months
-- as it is a diabetic dataset, it is important to check how likely the patients are readmitted based on their sugar levels
select A1Cresult, count(*) as total_encounters,
round(sum(readmitted='<30')/count(*)*100,1) as readmission_rate_pct
from diabetic_data_dedup
group by A1Cresult;

-- Finding 5) readmission based on gender category
select gender, count(*) as total_encounters,
round(sum(readmitted='<30')/count(*)*100,1) as readmission_rate_pct
from diabetic_data_dedup
group by gender;

-- Finding 6) readmission based emergency visits
select number_emergency, count(*) as total_encounters,
round(sum(readmitted='<30')/count(*) * 100,1) from diabetic_data_dedup
group by number_emergency;

-- Finding 7) patients with high healthcare utilitzation
-- this basically indicates the highest no of times that a patient gets a overnight visit in the hospital.
select patient_nbr, number_inpatient, number_outpatient,number_emergency, readmitted
from diabetic_data_dedup
order by number_inpatient desc;