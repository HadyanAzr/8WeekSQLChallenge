#  Case Study #4 - Data Bank

##  Solution - B. Customer Transactions

**1. What is the unique count and total amount for each transaction type?**

````sql
SELECT
	txn_type,
	COUNT(DISTINCT customer_id) AS unique_count,
	SUM(txn_amount) AS Total_transactions
FROM
	data_bank.customer_transactions
GROUP BY
	txn_type
ORDER BY
	Total_transactions
;
````

**Answer:**

|txn_type|unique_count|total_transactions|
|--------|------------|------------------|
|withdrawal|439         |793003            |
|purchase|448         |806537            |
|deposit |500         |1359168           |


***

**2. What is the average total historical deposit counts and amounts for all customers?**

````sql
SELECT
	COUNT(customer_id)/(SELECT COUNT (DISTINCT customer_id)
			 FROM data_bank.customer_transactions) AS avg_deposit_counts,
	ROUND(AVG(txn_amount),0) AS avg_deposit
FROM 
	data_bank.customer_transactions
WHERE
	txn_type = 'deposit'
		;
````
**Answer:**

|avg_deposit_counts|avg_deposit|
|------------------|-----------|
|5                 |509        |

***

**3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

````sql
WITH cte_table AS(
		SELECT
			customer_id,
			EXTRACT(MONTH FROM txn_date) as months,
			SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
			SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
			SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
		FROM
			data_bank.customer_transactions
		GROUP BY
			customer_id,
			months
		ORDER BY
			months,
			customer_id) 
		SELECT
			COUNT(customer_id)
		FROM 
			cte_table
		WHERE
			deposit_count > 1 AND (purchase_count >= 1 OR withdrawal_count >= 1)
		;
````

**Answer:**

|count|
|-----|
|611  |


***

**4. What is the closing balance for each customer at the end of the month? Also show the change in balance each month in the same table output.**

````sql
WITH cte_table AS(
	SELECT
		customer_id,
		EXTRACT(MONTH FROM txn_date) AS months,
		CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE 0 END AS deposit_amnt,
		CASE WHEN txn_type = 'purchase' THEN txn_amount ELSE 0 END AS purchase_amnt,
		CASE WHEN txn_type = 'withdrawal' THEN txn_amount ELSE 0 END AS withdrawal_amnt
	FROM 
		data_bank.customer_transactions
	GROUP BY
		customer_id,
		months,
		txn_type,
		txn_amount
	ORDER BY
		months,
		customer_id
		)
	SELECT
		customer_id,
		months,
		deposit_amnt - (purchase_amnt + withdrawal_amnt) AS closing_balance
	FROM cte_table
	GROUP BY
		customer_id,
		months,
		deposit_amnt,
		purchase_amnt,
		withdrawal_amnt
	ORDER BY
		months,
		customer_id
  LIMIT 10
		;
````

**Answer:**

|customer_id|months|closing_balance|
|-----------|------|---------------|
|1          |1     |312            |
|2          |1     |549            |
|3          |1     |144            |
|4          |1     |390            |
|4          |1     |458            |
|5          |1     |-826           |
|5          |1     |806            |
|5          |1     |974            |
|6          |1     |-11            |
|6          |1     |-40            |


***

**5. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, what percentage of customers:**

````sql
CREATE TEMP TABLE balance AS(
WITH cte_table AS(
	SELECT
		customer_id,
		EXTRACT(MONTH FROM txn_date) AS months,
		CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE 0 END AS deposit_amnt,
		CASE WHEN txn_type = 'purchase' THEN txn_amount ELSE 0 END AS purchase_amnt,
		CASE WHEN txn_type = 'withdrawal' THEN txn_amount ELSE 0 END AS withdrawal_amnt
	FROM 
		data_bank.customer_transactions
	GROUP BY
		customer_id,
		months,
		txn_type,
		txn_amount
	ORDER BY
		months,
		customer_id
		)
	SELECT
		customer_id,
		months,
		deposit_amnt - (purchase_amnt + withdrawal_amnt) AS closing_balance
	FROM cte_table
	GROUP BY
		customer_id,
		months,
		deposit_amnt,
		purchase_amnt,
		withdrawal_amnt
	ORDER BY
		months,
		customer_id
		)
	-- After that, we can find solution by finding different from next balance and current balance
	WITH next_balance_table AS(
	SELECT
		customer_id,
		months,
		closing_balance,
		lead(closing_balance) OVER(PARTITION BY customer_id ORDER BY months) AS next_balance
	FROM 
		balance),
	increased_balance AS(
	SELECT
		customer_id,
		months, 
		closing_balance,
		next_balance,
		ROUND((next_balance - closing_balance) / closing_balance,2) AS percentage
	FROM
		next_balance_table
	WHERE
		months = 1 AND
		next_balance > 0 AND
		closing_balance != 0
	GROUP BY
		customer_id, months, closing_balance, next_balance
	HAVING
		ROUND((next_balance - closing_balance) / closing_balance,2) > 0.05
		) 
	SELECT
		ROUND(100*COUNT(DISTINCT customer_id) /(SELECT COUNT(DISTINCT customer_id) FROM balance),2) AS increased_prctg
	FROM
		increased_balance
		;
 ````

**Answer :**

|increased_prctg|
|---------------|
|21.00          |
