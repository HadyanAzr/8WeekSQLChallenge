--A. Digital Analysis

-- Using the available datasets - answer the following questions using a single query for each one:

    --1. How many users are there?
	
select
	count(distinct user_id) as tot_unique_customer
from
	clique_bait.users
	;
    --2. How many cookies does each user have on average?
	
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
    --3. What is the unique number of visits by all users per month?
	
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
    --4. What is the number of events for each event type?
	
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
    --5. What is the percentage of visits which have a purchase event?

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
	
    --6. What is the percentage of visits which view the checkout page but do not have a purchase event?
	
select
	round(100*count(page_id)/(select count(page_id) from clique_bait.events),1) as prtg_checkout_no_purchase
from 
	clique_bait.events
where
	page_id = 12 and event_type <> 3

    --7. What are the top 3 pages by number of views?
	
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
	;
	
    --8. What is the number of views and cart adds for each product category?

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
    --9. What are the top 3 products by purchases?
	
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
	
--note : the tricky part when calculate purchased product is you need to find product in cart first and then find purchased product
-- purchases event_type have no direct relation to product page_name, it will give you confirmation page
-- so use visit_id where event_type is purchase to filtered

--B. Product Funnel Analysis

--Using a single SQL query - create a new output table which has the following details:

--1. How many times was each product viewed?
--2. How many times was each product added to cart?
--3. How many times was each product added to a cart but not purchased (abandoned)?
--4. How many times was each product purchased?

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

--Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

--Use your 2 new output tables - answer the following questions:

    --1.Which product had the most views, cart adds and purchases?
	
select * from summary
order by num_view desc
limit 1
;
    --2. Which product was most likely to be abandoned?

select * from summary
order by num_abandoned_cart desc
limit 1
;
    --3. Which product had the highest view to purchase percentage?

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
    --4. What is the average conversion rate from view to cart add?
	
select
	round(avg(conversion_rate),2) as avg_conversion
from(
select
	product_id,
	product_name,
	num_added_cart/num_view as conversion_rate
from
	summary) as conversion_table
;
    --5. What is the average conversion rate from cart add to purchase?

select
	round(avg(conversion_rate),2) as avg_purch_conversion
from(
select
	product_id,
	product_name,
	total_purchase/num_added_cart as conversion_rate
from
	summary) as conversion_table
