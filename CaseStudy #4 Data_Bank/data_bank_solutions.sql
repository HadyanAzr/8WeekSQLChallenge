--Case Study Questions
-
--The following case study questions include some general data exploration analysis for the nodes and transactions before diving right into the core business questions and finishes with a challenging final request!
--A. Customer Nodes Exploration

    --1. How many unique nodes are there on the Data Bank system?
	SELECT 
		COUNT(DISTINCT node_id) 
	FROM 
		data_bank.customer_nodes
	;
    --2. What is the number of nodes per region?
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
    --3. How many customers are allocated to each region?
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
    --4. How many days on average are customers reallocated to a different node?
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
    --5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
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
		

--B. Customer Transactions

    --1. What is the unique count and total amount for each transaction type?
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
    --2. What is the average total historical deposit counts and amounts for all customers?
		SELECT
			COUNT(customer_id)/(SELECT COUNT (DISTINCT customer_id)
							   FROM data_bank.customer_transactions) AS avg_deposit_counts,
			ROUND(AVG(txn_amount),0) AS avg_deposit
		FROM 
			data_bank.customer_transactions
		WHERE
			txn_type = 'deposit'
		;
    --3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
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
			
    --4. What is the closing balance for each customer at the end of the month?
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
		;
    --5. What is the percentage of customers who increase their closing balance by more than 5%?
	-- We create temporary table first from Question 4
	CREATE TEMP TABLE balance AS(WITH cte_table AS(
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
	-- After that, we can find solution by finding different from next balance and previous balance
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
		next_balance::TEXT NOT LIKE '-%' AND
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