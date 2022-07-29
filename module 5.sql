#$query = "UPDATE `db`.`table` SET `fieldname`=  str_to_date(  fieldname, '%d/%m/%Y')";
UPDATE job_description SET created = str_to_date(created, '%d/%m/%Y');
UPDATE job_description SET modified = str_to_date(modified, '%d/%m/%Y');
UPDATE job_description SET post_date = str_to_date(post_date, '%m/%d/%Y');
select * from job_description;
# Task 2

# a) CTE 
# Find the names of the company who offer salary more than 50000 and find where these companies are located and
# find the category and job board used for the job posting

WITH CTE_1 AS (
SELECT DISTINCT company_id,company_name
FROM company c
INNER JOIN location l ON c.location_id = l.location_id)
,
CTE_2 AS (
SELECT DISTINCT company_id,job_board,inferred_yearly_to
FROM job_description j
INNER JOIN fact_salary f
ON j.job_id = f.job_id
)

SELECT C1.company_id,C1.company_name,C2.job_board,C2.inferred_yearly_to
FROM CTE_1 C1
INNER JOIN CTE_2 C2
ON C1.company_id = C2.company_id
WHERE inferred_yearly_to > 40000;

# d) SELF JOIN
SELECT c1.company_id,c1.company_name,c2.company_lat,c2.company_lon,c2.location_id
FROM company c1
INNER JOIN company c2;

# e) Windows Function
With CTE1 AS(
SELECT distinct c.company_name,l.inferred_city,l.inferred_state,l.country_max_pay_range,f.inferred_yearly_to,
RANK () OVER (ORDER BY f.inferred_yearly_to desc) as 'rank'
FROM company c
INNER JOIN location l ON c.location_id = l.location_id
INNER JOIN fact_salary f ON l.location_id = f.location_id)

SELECT * FROM CTE1 c1
WHERE c1.rank = 1;
;
# f) Calculating running totals

SELECT c.company_id,c.company_name,l.inferred_city,SUM(f.inferred_yearly_from) OVER (ORDER BY f.company_id) AS cumulative_salary
FROM company c
INNER JOIN location l ON c.location_id = l.location_id
INNER JOIN fact_salary f ON l.location_id = f.location_id;

#EXCEPT VS NOT IN

select * from fact_salary
where salary_offered NOT IN
(select salary_offered from fact_salary);

WITH CTE_1 AS (
SELECT DISTINCT company_id,company_name
FROM company c
INNER JOIN location l ON c.location_id = l.location_id)
,
CTE_2 AS (
SELECT DISTINCT company_id,inferred_yearly_to,row_number () OVER (ORDER BY f.inferred_yearly_to desc) as 
'max_row_num',inferred_yearly_from,row_number () OVER (ORDER BY f.inferred_yearly_from ASC) as 
'min_row_num'
FROM job_description j
INNER JOIN fact_salary f
ON j.job_id = f.job_id
)

SELECT C1.company_id,C1.company_name,C2.inferred_yearly_to,C2.max_row_num,C2.inferred_yearly_from,C2.min_row_num
FROM CTE_1 C1
INNER JOIN CTE_2 C2
ON C1.company_id = C2.company_id
WHERE C2.max_row_num < 4 OR  C2.min_row_num < 4;

with CTE_1 AS (
SELECT l.inferred_city,f.inferred_yearly_to,row_number () OVER (partition by l.inferred_city ORDER BY f.inferred_yearly_to asc) as 
'max_row_num',f.inferred_yearly_from,row_number () OVER (partition by l.inferred_city ORDER BY f.inferred_yearly_from desc) as 
'min_row_num'
FROM location l
INNER JOIN fact_salary f
ON l.location_id = f.location_id)


SELECT max(CASE WHEN c1.max_row_num = 1 AND c1.inferred_city = 'Los Angeles' then c1.inferred_yearly_to end) as 'Los Angeles_max_salary',
min(CASE WHEN c1.min_row_num = 1 AND c1.inferred_city = 'Los Angeles' then c1.inferred_yearly_from end) as 'Los Angeles_min_salary',
max(CASE WHEN c1.max_row_num = 1 AND c1.inferred_city = 'Boston' then c1.inferred_yearly_to end) as 'Boston_max_salary',
min(CASE WHEN c1.min_row_num = 1 AND c1.inferred_city = 'Boston' then c1.inferred_yearly_from end) as 'Boston_min_salary',
max(CASE WHEN c1.max_row_num = 1 AND c1.inferred_city = 'Richmond' then c1.inferred_yearly_to end) as 'Richmond_max_salary',
min(CASE WHEN c1.min_row_num = 1 AND c1.inferred_city = 'Richmond' then c1.inferred_yearly_from end) as 'Richmond_min_salary',
max(CASE WHEN c1.max_row_num = 1 AND c1.inferred_city = 'New York' then c1.inferred_yearly_to end) as 'New York_max_salary',
min(CASE WHEN c1.min_row_num = 1 AND c1.inferred_city = 'New York' then c1.inferred_yearly_from end) as 'New York_min_salary',
max(CASE WHEN c1.max_row_num = 1 AND c1.inferred_city = 'Newark' then c1.inferred_yearly_to end) as 'Newark_max_salary',
min(CASE WHEN c1.min_row_num = 1 AND c1.inferred_city = 'Newark' then c1.inferred_yearly_from end) as 'Newark_min_salary'
FROM CTE_1 C1
LIMIT 1;

SELECT max(CASE WHEN c1.max_row_num = 1 AND c1.inferred_city = 'Boston' then c1.inferred_yearly_to end) as 'Boston_max_salary',
min(CASE WHEN c1.min_row_num = 1 AND c1.inferred_city = 'Boston' then c1.inferred_yearly_from end) as 'Boston_min_salary'
FROM CTE_1 C1
LIMIT 1;


