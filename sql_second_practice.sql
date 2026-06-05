-- 1.Retrieve the total number of orders placed
SELECT COUNT(order_id) AS total_orders FROM orders;

-- 2. Calculate the total revenue generated from pizza sales
SELECT round(SUM(order_deatils.quantity * pizzas.price), 2) AS total_revenue 
FROM 
	order_deatils 
		JOIN pizzas
ON pizzas.pizza_id = order_deatils.pizza_id;

-- 3. Identify the highest-priced pizza
SELECT pizza_types.name, pizzas.price
	FROM pizza_types 
		JOIN pizzas ON 
pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price 
desc limit 1;

-- 4. Identify the most common pizza size ordered.

SELECT pizzas.size, COUNT(order_deatils.order_details_id) AS order_count 
	FROM 
		pizzas Join order_deatils 
			ON pizzas.pizza_id = order_deatils.pizza_id 
GROUP BY pizzas.size 
ORDER BY order_count DESC;

-- 5. List the top 5 most ordered pizza types 
-- along with their quantities

SELECT pizza_types.name, SUM(order_deatils.quantity) AS quantity
	FROM pizza_types 
		JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
		JOIN order_deatils ON order_deatils.pizza_id = pizzas.pizza_id 
GROUP BY pizza_types.name 
ORDER BY quantity DESC limit 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered

SELECT 
    pizza_types.category,
    SUM(order_deatils.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_deatils ON order_deatils.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY quantity DESC;

-- 7. Determine the distribution of orders by hour of the day.

SELECT hour(order_time), count(order_id) FROM orders
GROUP BY hour(order_time);

-- 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_pizzas), 0)
FROM
    (SELECT 
        order_date, SUM(order_deatils.quantity) AS total_pizzas
    FROM
        orders
    JOIN order_deatils ON orders.order_id = order_deatils.order_id
    GROUP BY order_date) AS order_quantity;
    
-- 10. Determine the top 3 most ordered pizza types based on revenue

Select pizza_types.name, SUM(order_deatils.quantity * pizzas.price) as revenue
from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_deatils on order_deatils.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
  round(  (SUM(order_deatils.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_deatils.quantity * pizzas.price),
                        2) AS total_sales
        FROM
            order_deatils
                JOIN
            pizzas ON pizzas.pizza_id = order_deatils.pizza_id) )* 100, 2) as revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_deatils ON order_deatils.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

-- 12. Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_deatils.quantity * pizzas.price) as revenue
from order_deatils join pizzas on order_deatils.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_deatils.order_id
group by orders.order_date) as sales;


-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category

select name, revenue from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_deatils.quantity) * pizzas.price) as revenue 
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_deatils on order_deatils.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;