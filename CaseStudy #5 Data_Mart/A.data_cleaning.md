#  Case Study #5 - Data Mart

##  Solution - A. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the `data_mart` schema named `clean_weekly_sales`:
- Convert the `week_date` to a `DATE` format
- Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a `month_number` with the calendar month for each `week_date` value as the 3rd column
- Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called `age_band` after the original segment column using the following mapping on the number inside the segment value
  
<img width="166" alt="image" src="https://user-images.githubusercontent.com/81607668/131438667-3b7f3da5-cabc-436d-a352-2022841fc6a2.png">
  
- Add a new `demographic` column using the following mapping for the first letter in the `segment` values:  

| segment | demographic | 
| ------- | ----------- |
| C | Couples |
| F | Families |

- Ensure all `null` string values with an "unknown" string value in the original `segment` column as well as the new `age_band` and `demographic` columns
- Generate a new `avg_transaction` column as the sales value divided by transactions rounded to 2 decimal places for each record

**Answer:**

## Create New Table `sales_cleaned`

- Change week_date column format to **date**
````sql
ALTER TABLE data_mart.weekly_sales
ALTER COLUMN week_date TYPE date
USING WEEK_DATE::date;;
````
- After that, we create a new table that already cleaned

````sql
CREATE TABLE data_mart.sales_cleaned AS(
SELECT
	week_date,
	DATE_PART('week',week_date) AS week_number,
	DATE_PART('month',week_date) AS month_number,
	DATE_PART('year',week_date) AS year_number, --it should be calender_year but I forgot and named year_number instead.
	region,
	platform,
	CASE
		WHEN segment = 'null' THEN 'unknown' -- there are "null" values in segment column, replaced with "unknown"
		ELSE segment
		END AS segment,
	CASE 
		WHEN RIGHT(segment,1) = '1' THEN 'Young Adults' -- we can use RIGHT syntax CASE to select number from column segment to make new aged_band column
		WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
		WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
		ELSE 'unknown'
		END AS aged_band,
	CASE
		WHEN LEFT(segment,1) = 'C' THEN 'Couples' -- same with aged_band but we use LEFT syntax to select left side of text/number
		WHEN LEFT(segment,1) = 'F' THEN 'Families'
		ELSE 'unknown'
		END AS demographics,
	customer_type,
	transactions::numeric,
	sales::numeric,
	ROUND((sales::numeric/transactions::numeric),2) AS avg_transactions
FROM
	data_mart.weekly_sales)

````

|week_date |week_number|month_number|year_number|region|platform|segment|aged_band   |demographics|customer_type|transactions|sales   |avg_transactions|
|----------|-----------|------------|-----------|------|--------|-------|------------|------------|-------------|------------|--------|----------------|
|2020-08-31|36         |8           |2020       |ASIA  |Retail  |C3     |Retirees    |Couples     |New          |120631      |3656163 |30.31           |
|2020-08-31|36         |8           |2020       |ASIA  |Retail  |F1     |Young Adults|Families    |New          |31574       |996575  |31.56           |
|2020-08-31|36         |8           |2020       |USA   |Retail  |unknown|unknown     |unknown     |Guest        |529151      |16509610|31.20           |
|2020-08-31|36         |8           |2020       |EUROPE|Retail  |C1     |Young Adults|Couples     |New          |4517        |141942  |31.42           |
|2020-08-31|36         |8           |2020       |AFRICA|Retail  |C2     |Middle Aged |Couples     |New          |58046       |1758388 |30.29           |


***

