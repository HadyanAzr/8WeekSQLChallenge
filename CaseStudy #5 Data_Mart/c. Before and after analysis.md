#  Case Study #5 - Data Mart

##  Solution - C. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the `week_date` value of `2020-06-15` as the baseline week where the Data Mart sustainable packaging changes came into effect. We would include all `week_date` values for `2020-06-15` as the start of the period after the change and the previous week_date values would be before.

Using this analysis approach - answer the following questions:

**1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?**


````sql
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
	cte;
````
**Answer:**

|sales_4week_before|sales_4week_after|growth_rate|
|------------------|-----------------|-----------|
|2345878357        |2318994169       |-1.100     |


***

**2. What about the entire 12 weeks before and after?**

We can apply the same logic and solution to this question. 

````sql
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
	;
````

**Answer:**

|sales_12week_before|sales_12week_after|growth_rate|
|-------------------|------------------|-----------|
|7126273147         |6973947753        |-2.100     |


***

**3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?**

- 4 week before and after from 2018,2019 and 2020

````sql
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
  ;
````

**Answer:**

|year_number|sales_4week_before|sales_4week_after|growth_rate|
|-----------|------------------|-----------------|-----------|
|2018       |2125140809        |2129242914       |0.200      |
|2019       |2249989796        |2252326390       |0.100      |
|2020       |2345878357        |2318994169       |-1.100     |


- 12 week before and after from 2018,2019 and 2020

**
- Use the same solution above and change to week 13 to 24 for before and week 25 to 37 for after.

````sql
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
;
````

**Answer:**

|year_number|sales_12week_before|sales_12week_after|growth_rate|
|-----------|-------------------|------------------|-----------|
|2018       |6396562317         |6500818510        |1.600      |
|2019       |6883386397         |6862646103        |-0.300     |
|2020       |7126273147         |6973947753        |-2.100     |


***
