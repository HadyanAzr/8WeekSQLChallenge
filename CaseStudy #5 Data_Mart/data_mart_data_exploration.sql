--2. Data Exploration

--1. What day of the week is used for each week_date value?

SELECT
	DISTINCT TO_CHAR(week_date,'day') AS day_of_week
FROM
	data_mart.sales_cleaned
	;
	
--2. What range of week numbers are missing from the dataset?

SELECT
	52 - COUNT(DISTINCT week_number ) AS missing_week -- There are 52 weeks in a year
FROM
	data_mart.sales_cleaned
	;
	
--3. How many total transactions were there for each year in the dataset?

SELECT
	year_number,
	COUNT(transactions) AS num_of_transactions,
	SUM(transactions) AS total_of_transactions
FROM
	data_mart.sales_cleaned
GROUP BY
	year_number
ORDER BY
	year_number
	;
--4. What is the total sales for each region for each month?

SELECT
	month_number,
	region,
	SUM(sales) AS tot_sales
FROM
	data_mart.sales_cleaned
GROUP BY
	region,
	month_number
ORDER BY
	region,
	month_number
	;
--5. What is the total count of transactions for each platform

SELECT
	platform,
	COUNT(transactions) AS num_of_transactions
FROM
	data_mart.sales_cleaned
GROUP BY
	platform
	;
--6. What is the percentage of sales for Retail vs Shopify for each month?
SELECT
	year_number,
	month_number,
	100*ROUND(SUM(CASE
		WHEN platform = 'Retail' THEN sales ElSE NULL END)/
		SUM(sales),3) AS retail_percentage,
	100*ROUND(SUM(CASE
	   	WHEN platform = 'Shopify' THEN sales ELSE NULL END)/
		SUM(sales),3) AS shopify_percentage
FROM
	data_mart.sales_cleaned
GROUP BY
	year_number,
	month_number
ORDER BY
	year_number,
	month_number
	;
--7. What is the percentage of sales by demographic for each year in the dataset?
SELECT
	year_number,
	100*ROUND(SUM(CASE
		WHEN demographics = 'Couples' THEN sales ElSE NULL END)/
		SUM(sales),3) AS couples_percentage,
	100*ROUND(SUM(CASE
	   	WHEN demographics = 'Families' THEN sales ELSE NULL END)/
		SUM(sales),3) AS families_percentage,
	100*ROUND(SUM(CASE
	   	WHEN demographics = 'unknown' THEN sales ELSE NULL END)/
		SUM(sales),3) AS unknowns_percentage
FROM
	data_mart.sales_cleaned
GROUP BY
	year_number
ORDER BY
	year_number
	;
--8. Which age_band and demographic values contribute the most to Retail sales?

SELECT
	aged_band,
	demographics,
	SUM(sales) AS retail_sales
FROM
	data_mart.sales_cleaned
WHERE
	platform = 'Retail'
GROUP BY
	aged_band,
	demographics
ORDER BY
	retail_sales DESC
	;
--9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

SELECT
	year_number,
	ROUND(AVG(CASE
		WHEN platform = 'Retail' THEN avg_transactions ELSE NULL END),2) AS avg_retail,
	ROUND(AVG(CASE
	   WHEN platform = 'Shopify' THEN avg_transactions ELSE NULL END),2) AS avg_shopify
FROM 
	data_mart.sales_cleaned
GROUP BY
	year_number
ORDER BY
	year_number
	
--3. Before & After Analysis

--This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

--Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

--We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

--Using this analysis approach - answer the following questions:

--1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
	
with cte as(	
select
	sum(case
	   	when week_number between 21 and 24 then sales
	   else null end) AS sales_4week_before,
	sum(case
	   when week_number between 25 and 28 then sales
	   else null end) as sales_4week_after
from
	data_mart.sales_cleaned
where
	year_number = 2020)
	
select 
	*,
	100*ROUND(((sales_4week_after - sales_4week_before)/sales_4week_before),3) AS growth_rate
from
	cte
	
--2. What about the entire 12 weeks before and after?

with cte as(	
select
	sum(case
	   	when week_number between 13 and 24 then sales
	   else null end) AS sales_12week_before,
	sum(case
	   when week_number between 25 and 37 then sales
	   else null end) as sales_12week_after
from
	data_mart.sales_cleaned
where
	year_number = 2020)
	
select 
	*,
	100*ROUND((sales_12week_after - sales_12week_before)/sales_12week_before,3) AS growth_rate
from
	cte
--3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
-- 4 weeks before and after period
with cte as(	
select
	year_number,
	sum(case
	   	when week_number between 21 and 24 then sales
	   else null end) AS sales_4week_before,
	sum(case
	   when week_number between 25 and 28 then sales
	   else null end) as sales_4week_after
from
	data_mart.sales_cleaned
group by
	year_number)
	
select 
	*,
	100*ROUND(((sales_4week_after - sales_4week_before)/sales_4week_before),3) AS growth_rate
from
	cte
order by
	year_number

-- 12 week before and after period
with cte as(	
select
	year_number,
	sum(case
	   	when week_number between 13 and 24 then sales
	   else null end) AS sales_12week_before,
	sum(case
	   when week_number between 25 and 37 then sales
	   else null end) as sales_12week_after
from
	data_mart.sales_cleaned
group by
	year_number)
	
select 
	*,
	100*ROUND((sales_12week_after - sales_12week_before)/sales_12week_before,3) AS growth_rate
from
	cte
order by
	year_number
