#1.Show Total number of Job posts by each state,Average salaries based on states,
  # the difference in % between average salaries and the total salary in that state.
  
  SELECT l.inferred_state,(j.job_id) as Total_No_Of_Job_Post,
  (f.inferred_yearly_from+f.inferred_yearly_to/2) as Avg_salary,
  ((f.inferred_yearly_to-(f.inferred_yearly_from+f.inferred_yearly_to/2))/(l.country_max_pay_range)) as percent_diff
  FROM job_description j
  JOIN fact_salary f
  ON j.job_id = f.job_id
  JOIN location l
  ON f.location_id = l.location_id
  GROUP BY l.inferred_state;
  
 # 2. The percentage of cities that have <20% of job posts.
 
  With Tot_jobs as (
  select count(j.job_id) as Total_no_of_jobs
  FROM job_description j)
  ,
  Tot_jobs_state as (
   SELECT  l.inferred_state AS state, 
   count(distinct j.job_id) as tot_jobs_state
   FROM location l
   INNER JOIN fact_salary f
   ON  l.location_id = f.location_id
   INNER JOIN job_description j
   ON f.job_id = j.job_id
  group by l.inferred_state)
  
  SELECT T1.state,
  T1.tot_jobs_state*100/T2.Total_no_of_jobs AS job_percentage
  FROM Tot_jobs_state T1
  CROSS JOIN Tot_jobs T2
   WHERE T1.tot_jobs_state*100/T2.Total_no_of_jobs < 20;
  
   
  #3. Selecting the top 3 job boards by the highest percentage of job titles making over 
  #150K in salary annualy and have at least 10 job posts
  
CREATE TEMPORARY TABLE new_tbl
  With job_titles as(
  SELECT distinct j.job_board as job_board,
  j.job_title as job_title,
  row_number () over(partition by j.job_board order by j.job_board) AS job_row_num
  FROM job_description j)
,
salary as(    
SELECT distinct j.job_board as JOB_BOARD,
j.job_title AS JOB_TITLE,
 f.inferred_yearly_to AS annual_salary
FROM job_description j
LEFT JOIN fact_salary f
ON j.job_id = f.job_id
WHERE f.inferred_yearly_to > 150000)

SELECT distinct j.job_board
,j.job_title
,s.annual_salary
FROM job_titles j
LEFT JOIN salary s
ON j.job_title = s.JOB_TITLE
where s.annual_salary IS NOT NULL;


   
#4.Top 5 job salaries in US breaking down by job_type/time_unit 
#(Top Annual and Top Hourly rates) - use subquery or CTE

with hourly_rate as (
SELECT job_type,
hourly_salary,
 row_number() OVER (partition by JOB_TYPE ORDER BY hourly_salary desc) as hourly_num
 FROM(
SELECT distinct j.job_type AS job_type,
f.inferred_salary_to as hourly_salary
FROM job_description j
LEFT JOIN fact_salary f
ON j.job_id = f.job_id) as hourly_rates)
,
annual_rate as (
SELECT JOB_TYPE,
yearly_salary,
 row_number() OVER (partition by JOB_TYPE ORDER BY yearly_salary desc) as yearly_num
 FROM(
SELECT distinct j.job_type AS JOB_TYPE,
f.inferred_yearly_to as yearly_salary
FROM job_description j
LEFT JOIN fact_salary f
ON j.job_id = f.job_id) AS annual_rates)

Select H.job_type,
H.hourly_salary,
H.hourly_num,
A.yearly_salary,
A.yearly_num
FROM hourly_rate H
INNER JOIN annual_rate A
ON H.job_type = A.JOB_TYPE
WHERE H.hourly_num < 6 AND A.yearly_num < 6;


   
#5. Find hirest salaries per city in UK. In your output show Job_board, City, salary
  
  with cte1 as 
  (select J.job_board,
  l.inferred_city, 
  f.inferred_yearly_to,
  row_number() OVER (partition by l.inferred_city ORDER BY f.inferred_yearly_to asc) as 'max_row_num'
  FROM job_description j
  JOIN fact_salary f
  ON j.job_id = f.job_id
  JOIN location l
  ON f.location_id = l.location_id)
  
  select * from cte1 c1
  where c1.max_row_num = 1 AND l.inferred_country = 'United kingdom'
  
