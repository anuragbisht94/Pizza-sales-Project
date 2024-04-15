select * from dominos.pizzas;
select * from dominos.orders;
select * from dominos.pizza_type;
select * from dominos.order_details;

-- BASIC QUESTIONS --

-- Retrieve the total number of orders placed.
select count(*) AS Total_orders from dominos.orders;

-- Calculate the total revenue generated from pizza sales.
select sum(pizzas.price*order_details.quantity) over () as total_revenue from 
dominos.pizzas
join
dominos.order_details on
pizzas.pizza_id=order_details.pizza_id;

-- Identify the highest-priced pizza.
select pizza_type.name , price
from dominos.pizzas join dominos.pizza_type on
pizzas.pizza_type_id=pizza_type.pizza_type_id
where price = (select max(price) from pizzas);

-- Identify the most common pizza size ordered.
select pizzas.size,count(order_details.quantity) as total
from dominos.pizzas join
dominos.order_details on 
pizzas.pizza_id=order_details.pizza_id
group by pizzas.size 
order by total desc limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_type.name, sum(order_details.quantity) as times
from order_details
join
pizzas on
order_details.pizza_id=pizzas.pizza_id
join pizza_type on
pizza_type.pizza_type_id=pizzas.pizza_type_id
group by pizza_type.name
order by times desc limit 5;


-- Intermediate Question --

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_type.category, sum(order_details.quantity) as times
from order_details
join
pizzas on
order_details.pizza_id=pizzas.pizza_id
join pizza_type on
pizza_type.pizza_type_id=pizzas.pizza_type_id
group by pizza_type.category;

-- Determine the distribution of orders by hour of the day.
select count(order_id), 
extract(hour from order_time) as hour
from orders
group by hour
order by hour asc;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category ,count(pizza_type.name) as total_pizzas
from pizza_type 
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(total_order))from
(select orders.order_date as date, sum(order_details.quantity) as total_order
from orders join order_details on
orders.order_id=order_details.order_id
group by date)as total;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_type.name, sum(pizzas.price*order_details.quantity) as total_revenue from 
pizzas
join
order_details on
pizzas.pizza_id=order_details.pizza_id
join pizza_type on
pizzas.pizza_type_id= pizza_type.pizza_type_id
group by pizza_type.name
order by total_revenue desc limit 3;

-- Advanced Questions --
-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_type.name, sum(pizzas.price*order_details.quantity) as total_revenue, 
round(sum(pizzas.price*order_details.quantity)/ (select sum(pizzas.price*order_details.quantity) as total_revenue
from 
dominos.pizzas
join
dominos.order_details on
pizzas.pizza_id=order_details.pizza_id) * 100,2) as total_sales 
from 
pizzas
join
order_details on
pizzas.pizza_id=order_details.pizza_id
join pizza_type on
pizzas.pizza_type_id= pizza_type.pizza_type_id
group by pizza_type.name;

-- Analyze the cumulative revenue generated over time.
with my_cte as (select orders.order_date, round(sum(pizzas.price*order_details.quantity)) as revenue
from pizzas
join
order_details on
pizzas.pizza_id = order_details.pizza_id
join 
orders on
orders.order_id=order_details.order_id
group by order_date
order by order_date)
select order_date,revenue,sum(revenue) over(order by order_date rows unbounded preceding) as cum_revenue
from my_cte;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with my_cte as (select category,name,revenue, rank()over(Partition by category order by revenue desc) as ranking
from
(select pizza_type.category,pizza_type.name,
sum(pizzas.price*order_details.quantity) as revenue
from pizzas
join
order_details on
pizzas.pizza_id=order_details.pizza_id
join pizza_type on
pizzas.pizza_type_id= pizza_type.pizza_type_id
group by pizza_type.name, pizza_type.category
order by pizza_type.category) as total)
select * from my_cte
where ranking <=3;