# Case Study #6 - Clique Bait

## Solution - A. Digital Analysis

**1. How many users are there?**

````sql
select
	count(distinct user_id) as tot_unique_customer
from
	clique_bait.users
	;
````

|tot_unique_customer|
|-------------------|
|500                |


**2. How many cookies does each user have on average?**

````sql
select
	round(avg(num_cookies),2) as average_cookies
from(
select
	user_id,
	count(cookie_id) as num_cookies
from
	clique_bait.users
group by
	user_id) as cookies_table
	;
````

|average_cookies|
|---------------|
|3.56           |


**3. What is the unique number of visits by all users per month?**

````sql
select
	date_part('month', event_time) as months,
	count(distinct visit_id) as tot_visits
from
	clique_bait.events
group by
	months
order by
	months
  ;
````

|months|tot_visits|
|------|----------|
|1     |876       |
|2     |1488      |
|3     |916       |
|4     |248       |
|5     |36        |


**4. What is the number of events for each event type?**

````sql
select
	e.event_type,
	ei.event_name,
	count(e.event_type) as num_of_events
from
	clique_bait.events e
inner join 
	clique_bait.event_identifier ei on e.event_type = ei.event_type
group by
	e.event_type,
	ei.event_name
order by 
	e.event_type
	;
````

|event_type|event_name|num_of_events|
|----------|----------|-------------|
|1         |Page View |20928        |
|2         |Add to Cart|8451         |
|3         |Purchase  |1777         |
|4         |Ad Impression|876          |
|5         |Ad Click  |702          |


**5. What is the percentage of visits which have a purchase event?**

````sql
select
	event_name,
	round(100*num_of_events/(select count(distinct visit_id) from clique_bait.events),2) as purchase_percentage
from(
select
	e.event_type,
	ei.event_name,
	count(distinct e.visit_id) as num_of_events
from
	clique_bait.events e
inner join 
	clique_bait.event_identifier ei on e.event_type = ei.event_type
group by
	e.event_type,
	ei.event_name
order by 
	e.event_type) as num_events_table
where
	event_name = 'Purchase'
	;
````

|event_name|purchase_percentage|
|----------|-------------------|
|Purchase  |49.00              |


**6. What is the percentage of visits which view the checkout page but do not have a purchase event?**

````sql
with cte as(	
select
	visit_id,
	sum(case
		when event_type = 1 and page_id = 12 then 1 else 0 end) as checkout_page,
	sum(case 
		when event_type = 3 then 1 else 0 end) as purchase
from 
	clique_bait.events
group by
	visit_id)

select
	round(100*(1-(sum(purchase)/sum(checkout_page))),2) as checkout_without_purch_prctg
from cte
;
````

|checkout_without_purch_prctg|
|----------------------------|
|15.50                       |



**7. What are the top 3 pages by number of views?**

````sql
select
	e.page_id,
	ph.page_name,
	count(e.page_id) as num_views
from 
	clique_bait.events e
join
	clique_bait.page_hierarchy ph on e.page_id = ph.page_id
where
	e.event_type = 1
group by
	e.page_id,
	ph.page_name
order by
	num_views desc
limit 3
````
|page_id|page_name   |num_views|
|-------|------------|---------|
|2      |All Products|3174     |
|12     |Checkout    |2103     |
|1      |Home Page   |1782     |

**8. What is the number of views and cart adds for each product category?**

````sql
select
	ph.product_category,
	sum(case
	   when e.event_type = 2 then 1 else null end) as cart_adds,
	sum(case
	   when e.event_type = 1 then 1 else null end) as num_view
from 
	clique_bait.events e
join
	clique_bait.page_hierarchy ph on e.page_id = ph.page_id
where
	ph.product_id is not null
group by
	ph.product_category
;
````

|product_category|cart_adds   |num_view|
|----------------|------------|--------|
|Luxury          |1870        |3032    |
|Shellfish       |3792        |6204    |
|Fish            |2789        |4633    |


**9. What are the top 3 products by purchases?**

````sql

with cte as(
select
	distinct visit_id
from
	clique_bait.events
where
	event_type = 3), -- purchase event
cte2 as(
select
	e.visit_id,
	ph.product_id,
	ph.page_name as product_name,
	ph.product_category,
	case when e.event_type = 2 then 1 else 0 end added_cart,
	case when c.visit_id is not null then 1 else 0 end purchase
from
	clique_bait.events e
inner join
	clique_bait.page_hierarchy ph on e.page_id = ph.page_id
left join 
	cte c on c.visit_id = e.visit_id
where 
	product_id is not null)

select
	product_id,
	product_name,
	product_category,
	sum(case
	   when added_cart = 1 and purchase = 1 then 1 else 0 end) as tot_purchase
from
	cte2
group by
	product_id,
	product_name,
	product_category
order by
	tot_purchase desc
limit 3

````
***


|product_id|product_name|product_category|tot_purchase|
|----------|------------|----------------|------------|
|7         |Lobster     |Shellfish       |754         |
|9         |Oyster      |Shellfish       |726         |
|8         |Crab        |Shellfish       |719         |

