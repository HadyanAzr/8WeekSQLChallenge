# Case Study #2 Pizza Runner

## B. Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
SELECT
	DATE_TRUNC('WEEK', REGISTRATION_DATE) AS WEEK,
	COUNT(RUNNER_ID) AS CNT_RUNNER
FROM
	pizza_runner.runners
WHERE
	registration_date >= '2021-01-01'
GROUP BY
	WEEK
ORDER BY
	WEEK
;
````

**Answer:**

|week|cnt_runner|
|----|----------|
|2020-12-28 00:00:00+07|2         |
|2021-01-04 00:00:00+07|1         |
|2021-01-11 00:00:00+07|1         |

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
SELECT
	RUNNER_ID,
	ROUND(AVG(MINDIFF),1) AS AVGMIN
FROM (
SELECT
	RUNNER_ID,
	EXTRACT(MINUTE FROM RO.PICKUP_TIME - CO.ORDER_TIME) AS MINDIFF
FROM
	pizza_runner.runner_orders1 RO
JOIN
	PIZZA_RUNNER.customer_orders1 CO ON CO.order_id = RO.order_id
) AS TIME_TABLE
GROUP BY
	RUNNER_ID
ORDER BY
	RUNNER_ID 
;
````

**Answer:**
|runner_id|avgmin|
|---------|------|
|1        |15.3  |
|2        |23.4  |
|3        |10.0  |

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
SELECT
	NUM_PIZZA,
	ROUND(AVG(MINDIFF),1) AS PREP_TIME
FROM(
SELECT
	COUNT(CO.pizza_id) AS NUM_PIZZA,
	AVG(EXTRACT(MINUTE FROM RO.PICKUP_TIME - CO.ORDER_TIME)) AS MINDIFF
FROM
	pizza_runner.runner_orders1 RO
JOIN
	PIZZA_RUNNER.customer_orders1 CO ON CO.order_id = RO.order_id
GROUP BY
	CO.order_id) AS PIZZA_TIME
GROUP BY
	NUM_PIZZA 
;
````

**Answer:**

|num_pizza|prep_time|
|---------|---------|
|3        |29.0     |
|2        |18.0     |
|1        |12.0     |


- Semakin banyak pizza yang diorder maka durasi persiapan juga akan meningkat. 

### 4.  What was the average distance travelled for each customer?

````sql
SELECT
	CO.CUSTOMER_ID,
	ROUND(AVG(RO.DISTANCE),1) AS AVG_DIST
FROM
	pizza_runner.customer_orders1 CO 
JOIN
	pizza_runner.runner_orders1 RO ON RO.order_id = CO.order_id
GROUP BY
	CO.customer_id
ORDER BY
	CO.customer_id
;
````

**Answer:**

|customer_id|avg_dist|
|-----------|--------|
|101        |20.0    |
|102        |16.7    |
|103        |23.4    |
|104        |10.0    |
|105        |25.0    |


- Satuan jarak yang digunakan adalah KM

### 5. What was the difference between the longest and shortest delivery times for all orders?

````sql
SELECT
	MAX(DURATION) - MIN(DURATION) AS DEL_DIFF
FROM
	pizza_runner.runner_orders1
;	
````

**Answer:**

|del_diff|
|--------|
|30      |

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
SELECT
	order_id,
	distance, 
	Concat(Round(distance / (duration::numeric / 60),2),' ', 'Km/h')  AS spd
FROM
	pizza_runner.runner_orders1
WHERE
	duration IS NOT NULL
GROUP BY 
	order_ID,
	distance,
	duration
ORDER BY
	order_id
;
````

**Answer:**

|order_id|distance|spd       |
|--------|--------|----------|
|1       |20      |37.50 Km/h|
|2       |20      |44.44 Km/h|
|3       |13.4    |40.20 Km/h|
|4       |23.4    |35.10 Km/h|
|5       |10      |40.00 Km/h|
|7       |25      |60.00 Km/h|
|8       |23.4    |93.60 Km/h|
|10      |10      |60.00 Km/h|

### 7. What is the successful delivery percentage for each runner?

````sql
WITH CTE1 AS(
SELECT
	RUNNER_ID,
	COUNT(RUNNER_ID) AS SNUM_DEL
FROM 
	pizza_runner.runner_orders1
WHERE
	DISTANCE IS NOT NULL
GROUP BY 
	RUNNER_ID
ORDER BY 
	RUNNER_ID), 
CTE2 AS(
	SELECT
		RUNNER_ID,
		COUNT(RUNNER_ID::NUMERIC) AS TNUM_DEL
	FROM
		PIZZA_RUNNER.runner_orders1
	GROUP BY
		RUNNER_ID
	ORDER BY
		RUNNER_ID)
SELECT
	CTE1.RUNNER_ID,
	ROUND(100 * (CTE1.SNUM_DEL::NUMERIC / CTE2.TNUM_DEL::NUMERIC),2) AS DEL_PERCEN
FROM
	CTE1
JOIN 
	CTE2 ON CTE1.RUNNER_ID = CTE2.RUNNER_ID
GROUP BY
	CTE1.RUNNER_ID,
	DEL_PERCEN
ORDER BY
	CTE1.RUNNER_ID
````

````sql
-- Simple solution by KatieHuangX

SELECT runner_id, 
 ROUND(100 * SUM
  (CASE WHEN distance IS NULL THEN 0
  ELSE 1
  END) / COUNT(*), 0) AS success_perc
FROM pizza_runner.runner_orders1
GROUP BY runner_id
ORDER BY 
	runner_id;
````

**Answer:**

|runner_id|del_percen|
|---------|----------|
|1        |100.00    |
|2        |75.00     |
|3        |50.00     |

***
