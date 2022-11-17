# Case Study #2 - Pizza Runner

## Solution - A. Pizza Metrics

### 1. How many pizzas were ordered?

````sql
SELECT 
	COUNT(ORDER_ID) AS TOT_ORDER
FROM
	PIZZA_RUNNER.customer_orders1
  ;
````

**Answer:**

|tot_order|
|---------|
|14       |


### 2. How many unique customer orders were made?

````sql
SELECT
	COUNT(DISTINCT ORDER_ID) AS UNIQUE_ORDER
FROM
	PIZZA_RUNNER.customer_orders1
;
````

**Answer:**

|unique_order|
|------------|
|10          |

### 3. How many successful orders were delivered by each runner?

````sql
SELECT
	runner_id,
	COUNT(ORDER_ID) AS SC_ORDER
FROM	
	pizza_runner.runner_orders1
WHERE
	distance IS NOT NULL
GROUP BY
	runner_id
ORDER BY
	runner_id
;
````

**Answer:**

|runner_id|sc_order|
|---------|--------|
|1        |4       |
|2        |3       |
|3        |1       |


### 4. How many of each type of pizza was delivered?

````sql
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
	RO.distance IS NOT NULL
GROUP BY
	PN.pizza_id, 
	PN.pizza_name  
ORDER BY
	PN.pizza_id
;
````

**Answer:**

|pizza_id|pizza_name|del_pizza|
|--------|----------|---------|
|1       |Meatlovers|9        |
|2       |Vegetarian|3        |

### 5. How many Vegetarian and Meatlovers were ordered by each customer?**

````sql
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
````

**Answer:**

|customer_id|pizza_name|ord_pizza|
|-----------|----------|---------|
|101        |Meatlovers|2        |
|101        |Vegetarian|1        |
|102        |Meatlovers|2        |
|102        |Vegetarian|1        |
|103        |Meatlovers|3        |
|103        |Vegetarian|1        |
|104        |Meatlovers|3        |
|105        |Vegetarian|1        |


### 6. What was the maximum number of pizzas delivered in a single order?

````sql
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
	 RO.distance IS NOT NULL
	GROUP BY
		CO.ORDER_ID) AS ORDER_TABLE
;
````

**Answer:**

|max_del|
|-------|
|3      |

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
SELECT
	CO.CUSTOMER_ID,
	SUM(CASE
	   WHEN CO.EXCLUSIONS is NOT NULL OR CO.EXTRAS is not NULL THEN 1
	   ELSE 0
	   END) AS CHG,
	SUM(CASE
	   	WHEN CO.EXCLUSIONS is NULL AND CO.EXTRAS is NULL THEN 1
	   	ELSE 0
	   	END) AS NOCHG
FROM	
	pizza_runner.customer_orders1 CO
JOIN
	pizza_runner.runner_orders1 RO ON RO.order_id = CO.order_id
WHERE
	RO.distance IS NOT NULL
GROUP BY
	CUSTOMER_ID
ORDER by 
	CUSTOMER_ID
	;
````

**Answer:**

|customer_id|chg|nochg|
|-----------|---|-----|
|101        |2  |0    |
|102        |2  |1    |
|103        |3  |0    |
|104        |2  |1    |
|105        |1  |0    |


### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
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
	RO.distance IS NOT NULL
;
````

**Answer:**

|chg2|
|----|
|7   |

### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
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
````

**Answer:**

|hour_int|ordered_pizza|
|--------|-------------|
|2020-01-01 18:00:00|1            |
|2020-01-01 19:00:00|1            |
|2020-01-02 23:00:00|2            |
|2020-01-04 13:00:00|3            |
|2020-01-08 21:00:00|3            |
|2020-01-09 23:00:00|1            |
|2020-01-10 11:00:00|1            |
|2020-01-11 18:00:00|2            |

### 10. What was the volume of orders for each day of the week?

````sql
SELECT 
	TO_CHAR(ORDER_TIME, 'Day') AS WEEKDAY,
    COUNT(ORDER_ID) AS PIZZA_ORDERED
FROM 
	PIZZA_RUNNER.customer_orders1
GROUP BY 
	WEEKDAY
ORDER BY 
	WEEKDAY
; 
````

**Answer:**

|weekday|pizza_ordered|
|-------|-------------|
|Friday   |1            |
|Saturday |5            |
|Thursday |3            |
|Wednesday|5            |
