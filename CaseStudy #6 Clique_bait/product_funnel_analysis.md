# Case Study #6 - Clique Bait

## Solution - B. Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:

1. How many times was each product viewed?
2. How many times was each product added to cart?
3. How many times was each product added to a cart but not purchased (abandoned)?
4. How many times was each product purchased?

````sql
create temp table summary as
with cte1 as(
select
	e.visit_id,
	ph.product_id,
	ph.page_name as product_name,
	ph.product_category,
	sum(case
	   when e.event_type = 1 and ph.product_id is not null then 1 else 0 end) as page_view,
	sum(case
	   when e.event_type = 2 and ph.product_id is not null then 1 else 0 end) as added_cart
from
	clique_bait.events e
join
	clique_bait.page_hierarchy ph on e.page_id = ph.page_id
group by
	e.visit_id,
	ph.product_id,
	ph.page_name,
	ph.product_category),
cte2 as(
select
	distinct visit_id
from
	clique_bait.events
where
	event_type = 3), -- purchase event
cte3 as(
select
	c1.visit_id,
	c1.product_id,
	c1.product_name,
	c1.product_category,
	c1.page_view,
	c1.added_cart,
	case when c2.visit_id is not null then 1 else 0 end purchase
from
	cte1 c1
left join 
	cte2 c2 on c2.visit_id = c1.visit_id
where 
	product_id is not null)
	
select
	product_id,
	product_name,
	product_category,
	sum(page_view) as num_view,
	sum(added_cart) as num_added_cart,
	sum(case
	   when added_cart = 1 and purchase = 0 then 1 else 0 end) as num_abandoned_cart,
	sum(case
	   when added_cart = 1 and purchase = 1 then 1 else 0 end) as total_purchase
from
	cte3
group by
	product_id,
	product_name,
	product_category
order by product_id
;

select * from summary
;
````

|product_id|product_name|product_category|num_view|num_added_cart|num_abandoned_cart|total_purchase|
|----------|------------|----------------|--------|--------------|------------------|--------------|
|1         |Salmon      |Fish            |1559    |938           |227               |711           |
|2         |Kingfish    |Fish            |1559    |920           |213               |707           |
|3         |Tuna        |Fish            |1515    |931           |234               |697           |
|4         |Russian Caviar|Luxury          |1563    |946           |249               |697           |
|5         |Black Truffle|Luxury          |1469    |924           |217               |707           |
|6         |Abalone     |Shellfish       |1525    |932           |233               |699           |
|7         |Lobster     |Shellfish       |1547    |968           |214               |754           |
|8         |Crab        |Shellfish       |1564    |949           |230               |719           |
|9         |Oyster      |Shellfish       |1568    |943           |217               |726           |



## 1.Which product had the most views, cart adds and purchases?

````sql
select * from summary
order by num_view desc
limit 1
;
````

|product_id|product_name|product_category|num_view|num_added_cart|num_abandoned_cart|total_purchase|
|----------|------------|----------------|--------|--------------|------------------|--------------|
|9         |Oyster      |Shellfish       |1568    |943           |217               |726           |



## 2. Which product was most likely to be abandoned?

````sql
select * from summary
order by num_abandoned_cart desc
limit 1
;
````

|product_id|product_name|product_category|num_view|num_added_cart|num_abandoned_cart|total_purchase|
|----------|------------|----------------|--------|--------------|------------------|--------------|
|4         |Russian Caviar|Luxury          |1563    |946           |249               |697           |



## 3. Which product had the highest view to purchase percentage?

````sql
select
	product_id,
	product_name,
	product_category,
	num_view,
	total_purchase,
	round(100*total_purchase/num_view,2) as purchase_percentage
from
	summary
order by
	purchase_percentage desc
limit 3
;
````

|product_id|product_name|product_category|num_view|total_purchase|purchase_percentage|
|----------|------------|----------------|--------|--------------|-------------------|
|7         |Lobster     |Shellfish       |1547    |754           |48.74              |
|5         |Black Truffle|Luxury          |1469    |707           |48.13              |
|9         |Oyster      |Shellfish       |1568    |726           |46.30              |



## 4. What is the average conversion rate from view to cart add?

````sql
select
	round(avg(conversion_rate),2) as avg_conversion
from(
select
	product_id,
	product_name,
	100*num_added_cart/num_view as conversion_rate
from
	summary) as conversion_table
  ;
````

|avg_conversion|
|--------------|
|60.95         |



## 5. What is the average conversion rate from cart add to purchase?

````sql
select
	round(avg(conversion_rate),2) as avg_purch_conversion
from(
select
	product_id,
	product_name,
	100*total_purchase/num_added_cart as conversion_rate
from
	summary) as conversion_table
;
````

|avg_purch_conversion|
|--------------------|
|75.93               |
