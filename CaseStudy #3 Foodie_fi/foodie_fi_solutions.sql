-- A. Customer Journey

--Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
--Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

SELECT
	s.customer_id,
	p.plan_name,
	s.start_date
FROM
	foodie_fi.subscriptions s
JOIN
	foodie_fi."plans" p on p.plan_id = s.plan_id
WHERE
	customer_id IN (1,2,3,4,5,6,7,8)
ORDER BY
	customer_id,
	start_date	
;

-- B. Data Analysis Questions

    -- 1. How many customers has Foodie-Fi ever had?
    -- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
    -- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
    -- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
    -- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
    -- 6. What is the number and percentage of customer plans after their initial free trial?
    -- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
    -- 8. How many customers have upgraded to an annual plan in 2020?
    -- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
    -- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
    -- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

-- 1. How many customers has Foodie-Fi ever had?

	Select  
		count(DISTINCT customer_id) as Total_customer
	FROM
		foodie_fi.subscriptions
	;
-- 2. What is the monthly distribution of trial plan start_date values for our dataset 
-- use the start of the month as the group by value
	SELECT
		COUNT(*) as num_customer,
		DATE_TRUNC('MONTH', start_date) as months
	FROM
		foodie_fi.subscriptions
	GROUP BY
		months
	ORDER BY
		months
	;

-- 3. What plan start_date values occur after the year 2020 for our dataset? 
-- Show the breakdown by count of events for each plan_name

	SELECT
		p.plan_name,
		COUNT(p.plan_id) as num_events
	FROM 
		foodie_fi."plans" as p
	Join 
		foodie_fi.subscriptions as s on p.plan_id = s.plan_id
	WHERE
		s.start_date >= '2021-01-01'
	GROUP BY
		p.plan_name
	;
-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
	
	SELECT
		COUNT(customer_id) as num_churned,
		ROUND(COUNT(customer_id)*100/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions),1) AS Percentage
	FROM
		foodie_fi.subscriptions
	WHERE
		plan_id = 4 -- churn id
		;
		
-- 5. How many customers have churned straight after their initial free trial 
-- what percentage is this rounded to the nearest whole number?

	SELECT
		SUM(turn_churned) as num_churn,
		ROUND(SUM(turn_churned)*100/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions),1) as percentage
	FROM (
	SELECT
		customer_id,
		CASE
			WHEN plan_id = 4 
			AND
			LAG(plan_id) OVER(PARTITION BY customer_id order by start_date) = 0 -- trial id
			THEN 1
			ELSE 0
			END AS turn_churned
	FROM foodie_fi.subscriptions) AS churnedtable
	
-- 6. What is the number and percentage of customer plans after their initial free trial?
	SELECT
		plan_id,
		SUM(turn_plan) as num_customer,
		ROUND(SUM(turn_plan)*100/(SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions),1) as percentage
	FROM (
	SELECT
		plan_id,
		CASE
			WHEN plan_id != 0 
			AND
			LAG(plan_id) OVER(PARTITION BY customer_id order by start_date) = 0 -- trial id
			THEN 1
			ELSE 0
			END AS turn_plan
	FROM foodie_fi.subscriptions) AS turntable
	WHERE
		plan_id <> 0
	GROUP BY
		plan_id
	ORDER BY
		plan_id
	;
	
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH next_plan_table AS(
	Select
		*,
		lead(start_date,1) OVER(Partition by customer_id order by start_date) as next_plan
	FROM
		foodie_fi.subscriptions
	WHERE
		start_date <= '2020-12-31'),
	customer_breakdown AS (
	SELECT 
   		plan_id,
    	COUNT(DISTINCT customer_id) AS num_customers
 	FROM 
		next_plan_table
 	WHERE 
    	(next_plan IS NOT NULL AND (start_date < '2020-12-31' AND next_plan > '2020-12-31'))
    	OR (next_plan IS NULL AND start_date < '2020-12-31')
	GROUP BY 
		plan_id)
  
	SELECT
  		plan_id,
		num_customers,
		ROUND(num_customers::numeric * 100 /(SELECT COUNT(DISTINCT customer_id) 
									 FROM foodie_fi.subscriptions),1) AS percentage
	FROM
		customer_breakdown
	GROUP BY
		plan_id,
		num_customers
	ORDER BY
		plan_id

-- 8. How many customers have upgraded to an annual plan in 2020?
	
	SELECT
		COUNT(DISTINCT customer_id) as num_annual_cust
	FROM
		foodie_fi.subscriptions
	WHERE 
		plan_id = 3 and start_date <= '2020-12-31'
	;
	
 -- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
 WITH annual_table as(	
	SELECT
		customer_id,
	 	start_date as annual_date
	 from
	 	foodie_fi.subscriptions
	 Where
	 	plan_id = 3),
	trial_table as (
		Select 
			customer_id,
			start_date as trial_date
		from
			foodie_fi.subscriptions
		WHERE
			plan_id = 0)
	select
		ROUND(avg(annual_date - trial_date),0) as avg_up
	from
		annual_table a
	JOIN 
		trial_table t ON a.customer_id = t.customer_id
		
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

	WITH annual_table as(	
	SELECT
		customer_id,
	 	start_date as annual_date
	 from
	 	foodie_fi.subscriptions
	 Where
	 	plan_id = 3),
	trial_table as (
		Select 
			customer_id,
			start_date as trial_date
		from
			foodie_fi.subscriptions
		WHERE
			plan_id = 0),
	bins AS (
    SELECT 
		WIDTH_BUCKET(annual_date - trial_date, 0, 360, 12) AS days_period
    FROM 
		annual_table at
	JOIN 
		trial_table tt ON at.customer_id = tt.customer_id)
		
	SELECT
		((days_period - 1)*30 || '-' || (days_period)*30) AS _30days_period,
		COUNT(*)
	FROM
		bins
	GROUP BY
		days_period
	ORDER BY 
		days_period

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

	SELECT
		sum(downgrade) as num_downgrade
	FROM
	(SELECT
		customer_id,
		CASE
			WHEN plan_id = 1
			AND 
			lag(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) = 2
			THEN 1
			ELSE 0
			END AS downgrade
	FROM 
		foodie_fi.subscriptions
	WHERE
		start_date <= '2020-12-31') as downgrade_table