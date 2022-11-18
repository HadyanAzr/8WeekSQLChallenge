# 🥑 Case Study #3 - Foodie-Fi

## A. Customer Journey

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

````sql
SELECT
	s.customer_id,
	p.plan_name,
	s.start_date
FROM
	foodie_fi.subscriptions s
JOIN
	foodie_fi."plans" p on p.plan_id = s.plan_id
WHERE
	customer_id IN (1,2,11,13,15,16,18,19)
ORDER BY
	customer_id,
	start_date	
;
````
**Answer:**

|customer_id|plan_name    |start_date|
|-----------|-------------|----------|
|1          |trial        |2020-08-01|
|1          |basic monthly|2020-08-08|
|2          |trial        |2020-09-20|
|2          |pro annual   |2020-09-27|
|11         |trial        |2020-11-19|
|11         |churn        |2020-11-26|
|13         |trial        |2020-12-15|
|13         |basic monthly|2020-12-22|
|13         |pro monthly  |2021-03-29|
|15         |trial        |2020-03-17|
|15         |pro monthly  |2020-03-24|
|15         |churn        |2020-04-29|
|16         |trial        |2020-05-31|
|16         |basic monthly|2020-06-07|
|16         |pro annual   |2020-10-21|
|18         |trial        |2020-07-06|
|18         |pro monthly  |2020-07-13|
|19         |trial        |2020-06-22|
|19         |pro monthly  |2020-06-29|
|19         |pro annual   |2020-08-29|

**Notes :**
- Seperti terlihat pada tabel, setiap pelanggan memiliki pengalaman yang berbeda dengan pelanggan lainnya.
- Pelanggan dengan nomor ID 11 dan 15 memutuskan untuk tidak berlangganan pada akhirnya.


## 🎞 Solution - B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

````sql
Select  
		count(DISTINCT customer_id) as Total_customer
	FROM
		foodie_fi.subscriptions
	;
````
**Notes :**
- Penting sekali untuk menggunakan syntax **DISTINCT** disini, karena penggunaan syntax tersebut berguna mencari nilai __unik__ agar tidak terhitung duplikasi


**Answer:**

|total_customer|
|--------------|
|1000          |

- Ada 1000 pelanggan pada perusahaan foodie_fi


### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

````sql
SELECT
    TO_CHAR(start_date, 'Month') AS months,
		COUNT(*) as num_customer		
	FROM
		foodie_fi.subscriptions
	WHERE
		plan_id = 0
	GROUP BY
		months,
		EXTRACT(MONTH FROM start_date)
	ORDER BY
		EXTRACT(MONTH FROM start_date)
	;
````
**Notes :**
- Menghitung berapa banyak pelanggan dapat memakai syntax **COUNT**
- __trial_plan__ memiliki id = 0, maka kita filter pada WHERE clause

**Answer:**

|months|num_customer|
|------|------------|
|January  |88          |
|February |68          |
|March    |94          |
|April    |81          |
|May      |88          |
|June     |79          |
|July     |89          |
|August   |88          |
|September|87          |
|October  |79          |
|November |75          |
|December |84          |

- Jumlah pelanggan berstatus trial_plan paling banyak pada bulan Maret dan diikuti oleh bulan Juli 

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.

````sql
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
		p.plan_name,
		p.plan_id
	ORDER BY
		p.plan_id
	;
````

**Answer:**

|plan_name|num_events|
|---------|----------|
|basic monthly|8         |
|pro monthly|60        |
|pro annual|63        |
|churn    |71        |


### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

````sql
SELECT
		COUNT(customer_id) as num_churned,
		ROUND(COUNT(customer_id)::NUMERIC*100/(SELECT 
											   COUNT(DISTINCT customer_id) 
											   FROM foodie_fi.subscriptions),1) AS Percentage
	FROM
		foodie_fi.subscriptions
	WHERE
		plan_id = 4 -- churn id
		;
````
**Notes :**
- Untuk mencari perrsentase, hasil perhitungan churn dibagi dengan __Subquery__ hasil perhitungan seluruh pelanggan.
- Penting sekali untuk mengubah format hasil **COUNT** menjadi __Numeric__ agar hasil akurat

**Answer:**

|num_churned|percentage|
|-----------|----------|
|307        |30.7      |

- Sebanyak 307 pelanggan atau 30.7% pelanggan yang tidak berlangganan lagi. 

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

````sql
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
````
**Notes :**
- Pada kasus ini, perusahaan ingin mencari berapa banyak yang memutuskan untuk tidak berlangganan bahkan setelah diberikan free trial
- untuk menyelesaikan problem tersebut, syntax **LAG** atau **LEAD** dapat digunakan.
- Syntax tersebut dapat mencari nilai baris sebelumnya(**LAG**) atau nilai baris sesudahnya(**LEAD**), kali ini saya menggunakan **LAG**
- Kondisi yang ditetapkan adalah apabila nilai saat ini plan_id = 4(Churned) dan nilai sebelumnya adalah plan_id 0(free trial) maka terhitung 1.


**Answer:**

|num_churn|percentage|
|---------|----------|
|92       |9.0       |


- Ada 92 pelanggan atau 9% yang tidak berlangganan setelah free trial.


### 6. What is the number and percentage of customer plans after their initial free trial?

````sql
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
````
**Answer:**

|plan_id|num_customer|percentage|
|-------|------------|----------|
|1      |546         |54.0      |
|2      |325         |32.0      |
|3      |37          |3.0       |
|4      |92          |9.0       |


### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

````sql
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
    ;
````

**Answer:**

|plan_id|num_customers|percentage|
|-------|-------------|----------|
|0      |19           |1.9       |
|1      |224          |22.4      |
|2      |326          |32.6      |
|3      |195          |19.5      |
|4      |235          |23.5      |


### 8. How many customers have upgraded to an annual plan in 2020?

````sql
SELECT
		COUNT(DISTINCT customer_id) as num_annual_cust
	FROM
		foodie_fi.subscriptions
	WHERE 
		plan_id = 3 and start_date <= '2020-12-31'
````

**Answer:**

|num_annual_cust|
|---------------|
|195            |

### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

````sql
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
    ;
````

**Answer:**

|avg_up|
|------|
|105   |


- On average, it takes 105 days for a customer to upragde to an annual plan from the day they join Foodie-Fi.

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

````sql
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
    ;
````

**Answer:**

|_30days_period|count|
|--------------|-----|
|0-30          |48   |
|30-60         |25   |
|60-90         |33   |
|90-120        |35   |
|120-150       |43   |
|150-180       |35   |
|180-210       |27   |
|210-240       |4    |
|240-270       |5    |
|270-300       |1    |
|300-330       |1    |
|330-360       |1    |


### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

````sql
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
````

**Answer:**

|num_downgrade|
|-------------|
|0            |


Some of the solutions I got from [katiehuangx](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/B.%20Data%20Analysis%20Questions.md) repository especially Q7 to Q10.
I learned so much in this Case Studies, Thank you
