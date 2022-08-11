#1.Show Total number of Job posts by each state,Average salaries based on states,
  # the difference in % between average salaries and the total salary in that state.
  
  SELECT l.inferred_state,(j.job_id) as Total_No_Of_Job_Post,avg(f.salary_offered) as Avg_salary,
  ((l.country_max_pay_range-avg(f.salary_offered))/(l.country_max_pay_range))
  FROM job_description j
  JOIN fact_salary f
  ON j.job_id = f.job_id
  JOIN location l
  ON f.location_id = l.location_id
  GROUP BY l.inferred_state;
  
 # 2. The percentage of cities that have <20% of job posts.
  With CTE1 AS (
  SELECT l.inferred_state as state,  count(j.job_id) * 100.0 / sum(count(j.job_id))  over() as job_percentage
  FROM job_description j
  JOIN fact_salary f
  ON j.job_id = f.job_id
  JOIN location l
  ON f.location_id = l.location_id
  GROUP BY l.inferred_state
  )
  SELECT * FROM CTE1 C1
  WHERE C1.job_percentage < 20;
  
  #3. Selecting the top 3 job boards by the highest percentage of job titles making over 
  #150K in salary annualy and have at least 10 job posts
  
  With CTE1 AS (
  SELECT j.job_board,f.inferred_yearly_to,count(j.job_id) * 100.0 / sum(count(j.job_id))  over() as job_percentage
  FROM job_description j
  JOIN fact_salary f
  ON j.job_id = f.job_id
   GROUP BY j.job_board,f.inferred_yearly_to;
   
#4.Top 5 job salaries in US breaking down by job_type/time_unit 
#(Top Annual and Top Hourly rates) - use subquery or CTE
   
   
#5. Find hirest salaries per city in UK. In your output show Job_board, City, salary
  with cte1 as (select J.job_board,l.inferred_city, l.country_max_pay_range,row_number
  () OVER (partition by l.inferred_city ORDER BY l.country_max_pay_range asc) as 
'max_row_num'
  FROM job_description j
  JOIN fact_salary f
  ON j.job_id = f.job_id
  JOIN location l
  ON f.location_id = l.location_id)
  
  select * from cte1 c1
  where c1.max_row_num = 1