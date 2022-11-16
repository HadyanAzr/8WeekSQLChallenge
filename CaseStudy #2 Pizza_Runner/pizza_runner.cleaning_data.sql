SELECT order_id, customer_id, pizza_id, 
  CASE 
    WHEN exclusions IS null OR exclusions LIKE 'null' THEN NULL
    ELSE exclusions
    END AS exclusions,
  CASE 
    WHEN extras IS NULL or extras LIKE 'null' THEN NULL
    ELSE extras 
    END AS extras, 
  order_time
INTO pizza_runner.customer_orders1 
FROM pizza_runner.customer_orders;


SELECT order_id, runner_id,
  CASE 
    WHEN pickup_time LIKE 'null' THEN NULL
    ELSE pickup_time 
    END AS pickup_time,
  CASE 
    WHEN distance LIKE 'null' THEN NULL
    WHEN distance LIKE '%km' THEN TRIM('km' from distance) 
    ELSE distance END AS distance,
  CASE 
    WHEN duration LIKE 'null' THEN NULL 
    WHEN duration LIKE '%mins' THEN TRIM('mins' from duration) 
    WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)        
    WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)       
    ELSE duration END AS duration,
  CASE 
    WHEN cancellation IS NULL or cancellation LIKE 'null' THEN NULL
    ELSE cancellation END AS cancellation
INTO pizza_runner.runner_orders1
FROM pizza_runner.runner_orders;

ALTER TABLE pizza_runner.runner_orders1
ALTER COLUMN pickup_time TYPE TIMESTAMP USING pickup_time::timestamp without time zone,
ALTER COLUMN distance TYPE DECIMAL,
ALTER COLUMN duration TYPE INT USING duration::integer;