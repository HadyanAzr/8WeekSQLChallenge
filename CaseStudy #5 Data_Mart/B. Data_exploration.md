# 🛒 Case Study #5 - Data Mart

## 🛍 Solution - B. Data Exploration

**1. What day of the week is used for each week_date value?**

````sql
SELECT
	DISTINCT TO_CHAR(week_date,'day') AS day_of_week
FROM
	data_mart.sales_cleaned
	;
````

**Answer:**
|day_of_week|
|-----------|
|monday     |


**2. What range of week numbers are missing from the dataset?**

````sql
SELECT
	52 - COUNT(DISTINCT week_number ) AS missing_week -- There are 52 weeks in a year
FROM
	data_mart.sales_cleaned
	;
````

**Answer:**

|missing_week|
|------------|
|28          |


**3. How many total transactions were there for each year in the dataset?**

````sql
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
````

**Answer:**

|year_number|num_of_transactions|total_of_transactions|
|-----------|-------------------|---------------------|
|2018       |5698               |346406460            |
|2019       |5708               |365639285            |
|2020       |5711               |375813651            |


**4. What is the total sales for each region for each month?**

````sql
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
````

**Answer:**

|month_number|region|tot_sales|
|------------|------|---------|
|3           |AFRICA|567767480|
|4           |AFRICA|1911783504|
|5           |AFRICA|1647244738|
|6           |AFRICA|1767559760|
|7           |AFRICA|1960219710|


**5. What is the total count of transactions for each platform?**

````sql
SELECT
	platform,
	COUNT(transactions) AS num_of_transactions
FROM
	data_mart.sales_cleaned
GROUP BY
	platform
	;
````

**Answer:**

|platform  |num_of_transactions|
|----------|-------------------|
|Shopify   |8549               |
|Retail    |8568               |


**6. What is the percentage of sales for Retail vs Shopify for each month?**

````sql
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
````

**Answer:**

|year_number|month_number|retail_percentage|shopify_percentage|
|-----------|------------|-----------------|------------------|
|2018       |3           |97.900           |2.100             |
|2018       |4           |97.900           |2.100             |
|2018       |5           |97.700           |2.300             |
|2018       |6           |97.800           |2.200             |
|2018       |7           |97.800           |2.200             |


**7. What is the percentage of sales by demographic for each year in the dataset?**

````sql
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
````

**Answer:**

|year_number|couples_percentage|families_percentage|unknowns_percentage|
|-----------|------------------|-------------------|-------------------|
|2018       |26.400            |32.000             |41.600             |
|2019       |27.300            |32.500             |40.300             |
|2020       |28.700            |32.700             |38.600             |


**8. Which age_band and demographic values contribute the most to Retail sales?**

````sql
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
````

**Answer:**

|aged_band |demographics|retail_sales|
|----------|------------|------------|
|unknown   |unknown     |16067285533 |
|Retirees  |Families    |6634686916  |
|Retirees  |Couples     |6370580014  |
|Middle Aged|Families    |4354091554  |
|Young Adults|Couples     |2602922797  |
|Middle Aged|Couples     |1854160330  |
|Young Adults|Families    |1770889293  |


**9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**

````sql
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
	;
````

**Answer:**

|year_number|avg_retail|avg_shopify|
|-----------|----------|-----------|
|2018       |42.91     |188.28     |
|2019       |41.97     |177.56     |
|2020       |40.64     |174.87     |

