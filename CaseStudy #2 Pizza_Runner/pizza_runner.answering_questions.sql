-- A. Pizza Metrics
-- 1. How many pizzas were ordered?

SELECT 
	COUNT(ORDER_ID) AS TOT_ORDER
FROM
	PIZZA_RUNNER.customer_orders1
;
--2. How many unique customer orders were made?

SELECT
	COUNT(DISTINCT ORDER_ID) AS UNIQUE_ORDER
FROM
	PIZZA_RUNNER.customer_orders1
;
-- 3. How many successful orders were delivered by each runner?

SELECT
	runner_id,
	COUNT(ORDER_ID) AS SC_ORDER
FROM	
	pizza_runner.runner_orders1
WHERE
	cancellation NOT LIKE '%CANCEL%'
GROUP BY
	runner_id
ORDER BY
	runner_id
;

-- 4. How many of each type of pizza was delivered?

SELECT
	PN.pizza_id,
	PN.pizza_name,
	COUNT(CO.order_id) AS DEL_PIZZA
FROM	
	pizza_runner.pizza_names PN
JOIN 
	pizza_runner.customer_orders1 CO ON PN.pizza_id = CO.pizza_id
JOIN
	PIZZA_RUNNER.runner_orders1 RO ON CO.order_id = RO.order_id
WHERE
	RO.cancellation NOT LIKE '%CANCEL%'
GROUP BY
	PN.pizza_id, 
	PN.pizza_name  
ORDER BY
	PN.pizza_id
;

-- 5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
	CO.customer_id,
	PN.pizza_name,
	COUNT(CO.order_id) AS ORD_PIZZA
FROM
	pizza_runner.customer_orders1 CO 
JOIN
	pizza_runner.pizza_names PN ON CO.pizza_id = PN.pizza_id
GROUP BY
	CO.customer_id,
	PN.pizza_name
ORDER BY
	CO.customer_id
;

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT
	MAX(TOT_ORDER) AS MAX_DEL
FROM
	(SELECT
	 	CO.ORDER_ID,
		 COUNT(CO.PIZZA_ID) AS TOT_ORDER
	 FROM
		PIZZA_RUNNER.runner_orders1 RO
	JOIN
		PIZZA_RUNNER.customer_orders1 CO ON CO.order_id = RO.order_id
	 WHERE
	 RO.CANCELLATION NOT LIKE '%CANCEL%'
	GROUP BY
		CO.ORDER_ID) AS ORDER_TABLE
;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
 
SELECT
	CO.CUSTOMER_ID,
	SUM(CASE
	   WHEN CO.EXCLUSIONS is NOT NULL OR CO.EXTRAS is not NULL THEN 1
	   ELSE 0
	   END) AS CHG,
	SUM(CASE
	   	WHEN CO.EXCLUSIONS is not NULL OR CO.EXTRAS is not NULL THEN 1
	   	ELSE 0
	   	END) AS NOCHG
FROM	
	pizza_runner.customer_orders1 CO
JOIN
	pizza_runner.runner_orders1 RO ON RO.order_id = CO.order_id
WHERE
	RO.cancellation NOT LIKE '%CANCEL%'
GROUP BY
	CUSTOMER_ID
ORDER by 
	CUSTOMER_ID
	
-- 8.How many pizzas were delivered that had both exclusions and extras?

SELECT
	SUM(CASE
	   	WHEN CO.EXCLUSIONS is not NULL AND CO.extras is not NULL THEN 1
	   	ELSE 0
	   	END) AS CHG2
FROM	
	pizza_runner.CUSTOMER_ORDERS1 CO
JOIN
	pizza_runner.RUNNER_ORDERS1 RO ON CO.ORDER_ID = RO.ORDER_ID
WHERE
	RO.cancellation NOT LIKE '%CANCEL%'
;
	
-- 9.What was the total volume of pizzas ordered for each hour of the day?

SELECT
 	DATE_TRUNC('HOUR',ORDER_TIME) AS HOUR_INT,
	COUNT(ORDER_ID) AS ORDERED_PIZZA
FROM 
	PIZZA_RUNNER.CUSTOMER_ORDERS1
GROUP BY
	HOUR_INT
ORDER BY
	HOUR_INT
;

-- 10.What was the volume of orders for each day of the week?

SELECT TO_CHAR(ORDER_TIME, 'Day') AS WEEKDAY,
    COUNT(ORDER_ID) AS PIZZA_ORDERED
FROM PIZZA_RUNNER.customer_orders1
GROUP BY 
	WEEKDAY
ORDER BY 
WEEKDAY
; 

-- B. Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

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
	
-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
;
SELECT
	RUNNER_ID,
	AVG(MINDIFF) AS AVGMIN
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

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT
	NUM_PIZZA,
	AVG(MINDIFF) AS PREP_TIME
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
	NUM_PIZZA -- Result indicate there is relationship between number of pizza ordered and preparation time
;
-- 4. What was the average distance travelled for each customer?

SELECT
	CO.CUSTOMER_ID,
	ROUND(AVG(RO.DISTANCE),2) AS AVG_DIST
FROM
	pizza_runner.customer_orders1 CO 
JOIN
	pizza_runner.runner_orders1 RO ON RO.order_id = CO.order_id
GROUP BY
	CO.customer_id
ORDER BY
	CO.customer_id
;
-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT
	MAX(DURATION) - MIN(DURATION) AS DEL_DIFF
FROM
	pizza_runner.runner_orders1
;	
-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

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
-- 7. What is the successful delivery percentage for each runner?

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

-- Simple solution by Katie Huang Xiemin

SELECT runner_id, 
 ROUND(100 * SUM
  (CASE WHEN distance = 0 THEN 0
  ELSE 1
  END) / COUNT(*), 0) AS success_perc
FROM pizza_runner.runner_orders1
GROUP BY runner_id; -- use sum and case to sum success delivery and divided with count all rows.

C. Ingredient Optimisation

-- What are the standard ingredients for each pizza?
WITH CTE AS(
SELECT
	pizza_id, 
	UNNEST(
		   (STRING_TO_ARRAY(toppings,', '))) AS SEP_TOP
FROM 
pizza_runner.pizza_recipes
) 
SELECT
	CTE.PIZZA_ID,
	PT.TOPPING_NAME
FROM
	CTE
JOIN pizza_runner.pizza_toppings PT ON CTE.SEP_TOP::INTEGER = PT.topping_id
ORDER BY
	PIZZA_ID, 
	PT.topping_name
;
-- What was the most commonly added extra?

SELECT
	PT.topping_name,
	COUNT(SEP_EXT::INTEGER) AS CNT_EXT
FROM(
	SELECT UNNEST(
				STRING_TO_ARRAY(EXTRAS,', '))AS SEP_EXT
	FROM PIZZA_RUNNER.CUSTOMER_ORDERS1) AS EXT_TABLE
JOIN pizza_runner.pizza_toppings PT ON PT.topping_id = EXT_TABLE.SEP_EXT::INTEGER
GROUP BY
	PT.topping_name
ORDER BY
	PT.topping_name
;

-- What was the most common exclusion?

SELECT
	PT.topping_name,
	COUNT(SEP_EXCLUDE::INTEGER) AS CNT_EXCLUDE
FROM(
	SELECT UNNEST(
				STRING_TO_ARRAY(EXCLUSIONS,', '))AS SEP_EXCLUDE
	FROM PIZZA_RUNNER.CUSTOMER_ORDERS1) AS EXCLUDE_TABLE
JOIN pizza_runner.pizza_toppings PT ON PT.topping_id = EXCLUDE_TABLE.SEP_EXCLUDE::INTEGER
GROUP BY
	PT.topping_name
ORDER BY
	PT.topping_name
;
-- Generate an order item for each record in the customers_orders table in the format of one of the following:
  -- Meat Lovers
  -- Meat Lovers - Exclude Beef
  -- Meat Lovers - Extra Bacon
  -- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
  -- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
