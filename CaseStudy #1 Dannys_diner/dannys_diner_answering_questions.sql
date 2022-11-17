--  1. What is the total amount each customer spent at the restaurant?

with cnt AS(
    SELECT 
    	customer_id,
        product_id,
        COUNT(product_id) as cnt_p
    from dannys_diner.sales s
    group by
    	customer_id,
        product_id)
        
    select
    	cnt.customer_id,
        sum(cnt_p * m.price) as Total_spent
    from cnt
    join
    	dannys_diner.menu m on cnt.product_id = m.product_id
    group by
    	cnt.customer_id
    order by
    	cnt.customer_id
    ;
-- SIMPLE SOLUTION

SELECT customer_id, SUM(price) AS Total_amount_spent FROM dannys_diner.sales
JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?

Select 
    	customer_id,
        count(distinct order_date) as visit
    from dannys_diner.sales
    group by
    	customer_id
    order by
    	customer_id
    ;
	
-- 3. What was the first item from the menu purchased by each customer?
Select
   s.customer_id,
   m.product_name
from 
	dannys_diner.sales s 
join 
	dannys_diner.menu m ON s.product_id = m.product_id
group by
    s.customer_id,
    m.product_name,
    s.order_date
having
    s.order_date = (select
                       min(distinct order_date) as first_order
                       from dannys_diner.sales ss
                       join dannys_diner.menu mm on ss.product_id = mm.product_id)
order by
   s.customer_id
;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select 
    product_name,
    count(order_date) as most_purch
from 
    dannys_diner.menu m
join 
    dannys_diner.sales s ON m.product_id = s.product_id
group by
    product_name
order by
    most_purch desc
limit 1
    ;
-- 5. Which item was the most popular for each customer?

WITH CTE AS( 
SELECT 
	S.CUSTOMER_ID, 
	M.PRODUCT_NAME,
	COUNT(S.PRODUCT_ID) AS NUM_PURCHASES,
	DENSE_RANK() OVER (PARTITION BY S.CUSTOMER_ID ORDER BY COUNT(S.PRODUCT_ID) DESC) AS RANKING
FROM 
	dannys_diner.sales S  
JOIN 
	dannys_diner.menu M ON M.product_id = S.product_id
GROUP BY
	S.CUSTOMER_ID, 
	M.PRODUCT_NAME)
SELECT * FROM CTE
WHERE RANKING = 1
    ;
-- 6. Which item was purchased first by the customer after they became a member?

WITH FO AS(
    SELECT
      S.CUSTOMER_ID,
      ME.JOIN_DATE,
      S.ORDER_DATE,
      M.PRODUCT_ID,
      M.PRODUCT_NAME,
      DENSE_RANK() OVER(PARTITION BY S.CUSTOMER_ID ORDER BY S.ORDER_DATE) AS RANKING
    FROM
    	DANNYS_DINER.SALES S
    JOIN
    	DANNYS_DINER.MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
    JOIN
    	DANNYS_DINER.MEMBERS ME ON S.CUSTOMER_ID = ME.CUSTOMER_ID
    WHERE
    	S.ORDER_DATE >= ME.JOIN_DATE
        )
        
    SELECT
    	CUSTOMER_ID,
        ORDER_DATE,
        PRODUCT_ID,
        PRODUCT_NAME
    FROM
    	FO
    WHERE
    	RANKING = 1
    ;
-- 7. Which item was purchased just before the customer became a member?
WITH cte AS(
	SELECT
     S.CUSTOMER_ID,
      ME.JOIN_DATE,
      S.ORDER_DATE,
      M.PRODUCT_ID,
      M.PRODUCT_NAME,
	  DENSE_RANK() OVER(PARTITION BY S.customer_id ORDER BY S.order_date DESC) AS ranking
    FROM
    	DANNYS_DINER.SALES S
    JOIN
    	DANNYS_DINER.MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
    JOIN
    	DANNYS_DINER.MEMBERS ME ON S.CUSTOMER_ID = ME.CUSTOMER_ID
    WHERE
    	S.ORDER_DATE < ME.JOIN_DATE
    ORDER BY
    	S.ORDER_DATE)
	SELECT
		customer_id,
		join_date,
		order_date,
		product_id,
		product_name
	FROM
		cte
	WHERE
		ranking = 1
    ;
-- 8. What is the total items and amount spent for each member before they became a member? 
 
 SELECT
     	S.CUSTOMER_ID,
        COUNT(S.PRODUCT_ID) AS TOT_ITEM,
        SUM(MN.PRICE) AS TOT_SPENT
     FROM
     	DANNYS_DINER.SALES S
     JOIN
     	DANNYS_DINER.MENU MN ON S.PRODUCT_ID = MN.PRODUCT_ID
     JOIN 
     	DANNYS_DINER.MEMBERS ME ON S.CUSTOMER_ID = ME.CUSTOMER_ID
     WHERE
     	S.ORDER_DATE < ME.JOIN_DATE
     GROUP BY
     	S.CUSTOMER_ID
    ;
	
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
    	S.CUSTOMER_ID,
        SUM(CASE
            WHEN M.PRODUCT_ID = 1 THEN 20 * M.PRICE
            ELSE 10 * M.PRICE
            END) AS CUST_POINT
    FROM
    	DANNYS_DINER.SALES S 
    JOIN 
    	DANNYS_DINER.MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
    GROUP BY
    	S.CUSTOMER_ID
    ORDER BY
    	CUSTOMER_ID 
    ;
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
--how many points do customer A and B have at the end of January?
WITH CTE AS 
(
   SELECT *, 
     JOIN_DATE + 6 AS VALID_DATES
   FROM DANNYS_DINER.members 
)

SELECT
    	S.CUSTOMER_ID,
        SUM(CASE
            WHEN S.ORDER_DATE BETWEEN MM.JOIN_DATE AND CTE.VALID_DATES and S.CUSTOMER_ID = 'A' THEN 20 * M.PRICE
            WHEN S.ORDER_DATE BETWEEN MM.JOIN_DATE AND CTE.VALID_DATES and S.CUSTOMER_ID = 'B' THEN 20 * M.PRICE
            ELSE 10 * M.PRICE
            END) AS TOT_POINTS
    FROM
    	DANNYS_DINER.SALES S 
    JOIN 
    	DANNYS_DINER.MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
    JOIN
    	DANNYS_DINER.MEMBERS MM ON S.CUSTOMER_ID = MM.CUSTOMER_ID
	JOIN 
		CTE ON CTE.CUSTOMER_ID = S.CUSTOMER_ID
    WHERE
    	S.CUSTOMER_ID = 'A' OR S.CUSTOMER_ID = 'B'
        AND
        S.ORDER_DATE BETWEEN MM.JOIN_DATE AND '2021-01-31'
    GROUP BY
    	S.CUSTOMER_ID
    ORDER BY
    	CUSTOMER_ID 
    ;
