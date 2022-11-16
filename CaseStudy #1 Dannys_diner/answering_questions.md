# 🍜 Case Study #1: Danny's Diner

## Solution

View the complete syntax [here](https://github.com/HadyanAzr/8WeekSQLChallenge/blob/main/CaseStudy%20%231%20Dannys_diner/dannys_diner_answering_questions.sql).

***

### 1. What is the total amount each customer spent at the restaurant?

````sql
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
````

#### Answer:

|customer_id|total_spent|
|-----------|-----------|
|A          |76         |
|B          |74         |
|C          |36         |

***

### 2. How many days has each customer visited the restaurant?

````sql
Select 
    	customer_id,
        count(distinct order_date) as visit
    from dannys_diner.sales
    group by
    	customer_id
    order by
    	customer_id
    ;
````

#### Notes:
- Syntax **DISTINCT** digunakan untuk mendapatkan hasil unik tanpa duplikasi pada data sedangkan **COUNT** untuk mencari berapa banyak ```visit``` pada setiap customer.


#### Answer:
|customer_id|visit|
|-----------|-----|
|A          |4    |
|B          |6    |
|C          |2    |


***

### 3. What was the first item from the menu purchased by each customer?

````sql
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
````

#### Notes:
- Pendekatan yang dilakukan adalah membuat filter dengan **Having** clause dimana mencari order_date dengan nilai **min** pada data.
- Nilai tersebut merupakan tanggal pertama kali pelanggan melakukan pembelian terhadap item 

#### Answer:
|customer_id|product_name|
|-----------|------------|
|A          |curry       |
|A          |sushi       |
|B          |curry       |
|C          |ramen       |


***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
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
````

#### Notes:
- Jika hanya mencari produk mana yang paling banyak dibeli, maka dapat mengurutkan hasil **COUNT** secara descending lalu berikan syntax **LIMIT** 1 untuk membatasi hasil.

#### Answer:
|product_name|most_purch|
|------------|----------|
|ramen       |8         |


***

### 5. Which item was the most popular for each customer?

````sql
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
````

#### Notes:
- Pendekatan yang dilakukan dengan membuat tabel sementara, lalu mencari ```ranking``` menggunakan syntax **DENSE_RANK**
- Syntax **DENSE_RANK** akan membuat kolom baru dengan nilai ranking banyaknya item yang dibeli
- Query terakhir cukup memfilter Ranking = 1, ini akan memberikan hasil sebegai berikut :

#### Answer:
|customer_id|product_name|num_purchases|ranking|
|-----------|------------|-------------|-------|
|A          |ramen       |3            |1      |
|B          |sushi       |2            |1      |
|B          |curry       |2            |1      |
|B          |ramen       |2            |1      |
|C          |ramen       |3            |1      |


***

### 6. Which item was purchased first by the customer after they became a member?

````sql
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
````

#### Notes:
- Penyelesaian problem ini tidak jauh berbeda dengan Q5, hanya saja pada syntax **WHERE** kita memberi syarat bahwa ```order_date``` harus lebih dibanding ```join_date```

#### Answer:
|customer_id|order_date|product_id|product_name|
|-----------|----------|----------|------------|
|A          |2021-01-07|2         |curry       |
|B          |2021-01-11|1         |sushi       |

***

### 7. Which item was purchased just before the customer became a member?

````sql
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
    ;
````

#### Notes:
- Pengerjaan kurang lebih masih sama dengan soal sebelumnya, pada **DENSE_RANK** urutan ranking secara DESC karena kita ingin mencari pesanan sebelum terakhir sebelum pelanggan menjadi member.
- Untuk soal ini cukup simpel, kuncinya melakukan filter dimana ```order_date``` lebih kecil dibanding ```join_date```

#### Answer:
|customer_id|join_date|order_date|product_id|product_name|
|-----------|---------|----------|----------|------------|
|A          |2021-01-07|2021-01-01|1         |sushi       |
|A          |2021-01-07|2021-01-01|2         |curry       |
|B          |2021-01-09|2021-01-04|1         |sushi       |


***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
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

````

#### Notes:
- Mencari ```total_item``` dapat menggunakan **COUNT** ```product_id``` lalu untuk mengetahui berapa banyak pengeluaran pelanggan menggunakan syntax **SUM**
- Soal meminta pengeluaran sebelum menjadi member maka kita lakukan filter **WHERE** ```order_date``` lebih kecil dari ```join_date```.

#### Answer:
|customer_id|tot_item|tot_spent|
|-----------|--------|---------|
|B          |3       |40       |
|A          |2       |25       |

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
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
````

#### Steps:
- Perusahaan ingin memberikan 10 point setiap $1 yang dikeluarkan oleh pelanggan dan 20 point jika produk tersebut adalah sushi
- Kita dapat menggunakan **SUM** yang dikombinasikan dengan **CASE**, sushi memiliki ```product_id``` = 1 maka kita masukkan pada persyaratan Query.

#### Answer:
|customer_id|cust_point|
|-----------|----------|
|A          |860       |
|B          |940       |
|C          |360       |

***

### 10. 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
WITH CTE AS (
   SELECT *, 
     JOIN_DATE + 6 AS VALID_DATES
   FROM DANNYS_DINER.members)

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
````

#### Notes:
- Pada minggu pertama setelah pelanggan menjadi member maka poin mereka akan dikali 2, maka kita tetapkan terlebih dahulu ```valid_dates``` sebagai bataas bonus.
- lalu menggunakan kombinasi **SUM** dan **CASE** untuk menghitung berapa banyak bonus dari ```join_date``` sampai ```valid_dates```
- yang terakhir, memberikan filter dimana batas perhitungan hanya sampai pada akhir bulan Januari

#### Answer:
|customer_id|tot_points|
|-----------|----------|
|A          |1270      |
|B          |320       |

***
