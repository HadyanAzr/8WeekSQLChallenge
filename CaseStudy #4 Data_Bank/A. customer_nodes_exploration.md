# Case Study #4 - Data Bank

## Solution - A. Customer Nodes Exploration

**1. How many unique nodes are there on the Data Bank system?**

````sql
SELECT 
		COUNT(DISTINCT node_id) 
	FROM 
		data_bank.customer_nodes
	;
````

**Answer:**
|count|
|-----|
|5    |


***

**2. What is the number of nodes per region?**

````sql
SELECT
		r.region_id,
		r.region_name,
		COUNT(cn.node_id) AS num_of_nodes
	FROM
		data_bank.customer_nodes cn
	JOIN
		data_bank.regions r ON r.region_id = cn.region_id
	GROUP BY
		r.region_id,
		r.region_name
	ORDER BY
		r.region_id
	;
````

**Answer:**

|region_id|region_name|num_of_nodes|
|---------|-----------|------------|
|1        |Australia  |770         |
|2        |America    |735         |
|3        |Africa     |714         |
|4        |Asia       |665         |
|5        |Europe     |616         |


***

**3. How many customers are allocated to each region?**

````sql
SELECT
		r.region_id,
		r.region_name,
		COUNT(DISTINCT cn.customer_id) as num_of_customer
	FROM
		data_bank.customer_nodes cn
	JOIN
		data_bank.regions r ON r.region_id = cn.region_id
	GROUP BY
		r.region_id,
		r.region_name
	ORDER BY
		r.region_id
	;
````

**Answer:**

|region_id|region_name|num_of_customer|
|---------|-----------|---------------|
|1        |Australia  |110            |
|2        |America    |105            |
|3        |Africa     |102            |
|4        |Asia       |95             |
|5        |Europe     |88             |


***

**4. How many days on average are customers reallocated to a different node?**

````sql
SELECT
		ROUND(AVG(datediff),0) as average_day
	FROM(
	SELECT
		end_date - start_date as datediff
	FROM
		data_bank.customer_nodes
	WHERE
		end_date <> '9999-12-31') as datediff_table
		;
````

**Answer:**

|average_day|
|-----------|
|15         |

***

**5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**

````sql
WITH reallocation_table AS(
	SELECT
		cn.region_id,
		r.region_name,
		cn.end_date - cn.start_date AS datediff
	FROM
		data_bank.customer_nodes cn
	JOIN
		data_bank.regions r ON r.region_id = cn.region_id
	WHERE
		end_date <> '9999-12-31')
	SELECT
		region_id,
		region_name,
		PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY datediff asc) AS median,
		PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY datediff asc) AS _80th_percentile,
		PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY datediff asc) AS _95th_percentile
	FROM
		reallocation_table
	GROUP BY
		region_id,
		region_name
	ORDER BY
		region_id
	;
````

**Answer:**

|region_id|region_name|median|_80th_percentile|_95th_percentile|
|---------|-----------|------|----------------|----------------|
|1        |Australia  |15    |23              |28              |
|2        |America    |15    |23              |28              |
|3        |Africa     |15    |24              |28              |
|4        |Asia       |15    |23              |28              |
|5        |Europe     |15    |24              |28              |

***
