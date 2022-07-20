
# TASK 1 - Create a script to fing the duplicates in one of the tables

select company_name,company_lat,company_lon,count(*) as 'TOTAL_COUNT'
from company
GROUP BY company_name,company_lat,company_lon
HAVING COUNT(*) > 1;

#TASK 2 - Remove Duplicate values

DELETE FROM contact
WHERE 
company_name,company_lat,company_lon IN ( SELECT company_name,company_lat,company_lon FROM
(select company_name,company_lat,company_lon,ROW_NUMBER() OVER (partition by company_name,company_lat,company_lon
order by  company_name,company_lat,company_lon) Rownumber
from company) contact
where contact.Rownumber >1
);

# TASK 3 - CASE WHEN

SELECT 
*,CASE
			 WHEN is_remote = 1 THEN 'Remote'
			 WHEN is_remote = 0 THEN 'Not Remote'
             ELSE 'Unclassified'
             END AS 'Work_Status'
FROM job_description;

#TASK 4 - Coalesce

SELECT job_title,job_type, coalesce(category,'NO INFO') AS category
FROM job_description;

#TASK 5 - LEAST/GREATEST
SELECT inferred_city,inferred_state,inferred_country, GREATEST(20000,country_min_pay_range) AS country_min_pay_range
FROM location;
             
# TASK 6 - DISTINCT

SELECT DISTINCT *
FROM COMPANY;
