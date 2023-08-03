-- Data analysis on Film Rental dataset
use film_rental;
-- 1. What is the total revenue generated from all rentals in the database? 
SELECT SUM(amount) AS total_revenue
FROM payment;
-- 2. How many rentals were made in each month_name? 
SELECT * FROM rental;
SELECT DISTINCT MONTHNAME(rental_date) AS month,COUNT(rental_id) OVER(PARTITION BY MONTHNAME(rental_date)) AS no_of_rentals FROM rental;
-- 3. What is the rental rate of the film with the longest title in the database? 
SELECT rental_rate
FROM film
WHERE length(title) = (SELECT MAX(length(title)) FROM film);
-- 4. What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")? 
SELECT AVG(f.rental_rate) AS average_rental_rate
FROM film f
JOIN inventory i USING(film_id)
JOIN rental r using(inventory_id)
WHERE r.rental_date >= DATE_SUB('2005-05-05 22:04:30', INTERVAL 30 DAY);

-- 5. What is the most popular category of films in terms of the number of rentals? 
SELECT c.name AS category, COUNT(*) AS rental_count
FROM category c
JOIN film_category fc using(category_id)
JOIN inventory i using(film_id)
JOIN rental r using(inventory_id)
GROUP BY c.name
ORDER BY rental_count DESC
LIMIT 1;
-- 6. Find the longest movie duration from the list of films that have not been rented by any customer. 
SELECT MAX(f.length) AS longest_duration_in_seconds
FROM film f
LEFT JOIN inventory i using(film_id)
LEFT JOIN rental r using(inventory_id)
WHERE r.rental_id IS NULL;
-- 7. What is the average rental rate for films, broken down by category?
SELECT name AS category, AVG(rental_rate) AS avg_rental_rate
FROM category
JOIN film_category USING (category_id)
JOIN film USING (film_id)
GROUP BY 1; 
-- 8. What is the total revenue generated from rentals for each actor in the database? 
SELECT a.actor_id, a.first_name, a.last_name, SUM(p.amount) AS total_revenue
FROM actor a
JOIN film_actor fa using(actor_id)
JOIN film f using(film_id)
JOIN inventory i using(film_id)
JOIN rental r using(inventory_id)
JOIN payment p using(rental_id)
GROUP BY a.actor_id, a.first_name, a.last_name;
-- 9. Show all the actresses who worked in a film having a "Wrestler" in the description.  
SELECT DISTINCT a.actor_id, a.first_name, a.last_name
FROM actor a
JOIN film_actor fa using(actor_id)
JOIN film f using(film_id)
WHERE f.description LIKE '%Wrestler%';# gender column is not there in actors table so we cannot get the actresses
-- 10. Which customers have rented the same film more than once? 
with cte1 as
(select customer_id,film_id,count(film_id) over(partition by customer_id,film_id) as repeat_purchase
from customer join rental using (customer_id)
join inventory using (inventory_id))
select distinct customer_id from cte1 where repeat_purchase > 1;
-- 11. How many films in the comedy category have a rental rate higher than the average rental rate? 
SELECT COUNT(*) AS film_count
FROM film f
JOIN film_category fc using(film_id)
JOIN category c using(category_id)
WHERE c.name = 'Comedy' AND f.rental_rate > (SELECT AVG(rental_rate)FROM film);

with cte1 as
(select film_id,rental_rate,name,avg(rental_rate) over() as avg_rental
from film join film_category using(film_id)
join category using (category_id) where name ='comedy')
select count(distinct film_id) from cte1 where rental_rate > avg_rental;
-- 12. Which films have been rented the most by customers living in each city? 
SELECT ci.city, f.film_id, f.title, COUNT(*) AS rental_count
FROM City ci
JOIN Address a using(city_id) JOIN customer c using(address_id)
JOIN rental r using(customer_id) JOIN inventory i using(inventory_id)
JOIN film f using(film_id)
GROUP BY ci.city, f.film_id, f.title
HAVING rental_count = (SELECT MAX(rental_count)
    FROM (SELECT ci.city, f.film_id, COUNT(*) AS rental_count FROM City ci
        JOIN Address a using(city_id) JOIN customer c using(address_id)
        JOIN rental r using(customer_id) JOIN inventory i using(inventory_id)
        JOIN film f using(film_id)
        GROUP BY ci.city, f.film_id) AS film_counts
    WHERE film_counts.city = ci.city);
    
    
    with cte2 as
    (with cte1 as
    (select city_id,film_id,count(film_id) as rented_count
    from customer join rental using(customer_id)
    join inventory using(inventory_id)
    join address using (address_id) group by city_id,film_id)
    select city_id,film_id,rented_count,
    rank() over(partition by city_id order by rented_count desc) as rank_count from cte1)
    select city_id,film_id from cte2 where rank_count = 1;
-- 13. What is the total amount spent by customers whose rental payments exceed $200? 
SELECT customer_id,SUM(amount) AS  total_amount 
FROM payment GROUP BY customer_id HAVING total_amount>200;
-- 14. Display the fields which are having foreign key constraints related to the "rental" table. 
SELECT TABLE_NAME,COLUMN_NAME,CONSTRAINT_NAME,REFERENCED_TABLE_NAME,REFERENCED_COLUMN_NAME,REFERENCED_TABLE_SCHEMA
FROM
  INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
  REFERENCED_TABLE_NAME = 'rental';
-- 15. Create a View for the total revenue generated by each staff member, broken down by store city with the country name. 
CREATE VIEW staff_revenue_view AS
SELECT s.staff_id, s.first_name, s.last_name, s.store_id, c.city, co.country, SUM(p.amount) AS total_revenue
FROM staff s
JOIN store st using(store_id)
JOIN address a ON st.address_id = a.address_id
JOIN city c using(city_id)
JOIN payment p using(staff_id)
join country co using(country_id)
GROUP BY s.staff_id, s.first_name, s.last_name, s.store_id, c.city, co.country;
SELECT * FROM staff_revenue_view;
-- 16. Create a view based on rental information consisting of visiting_day, customer_name, the title of the film, no_of_rental_days,
-- the amount paid by the customer along with the percentage of customer spending. 
CREATE VIEW rental_details_view AS
SELECT DATE(r.rental_date) AS visiting_day,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,f.title AS film_title,
    DATEDIFF(r.return_date, r.rental_date) AS no_of_rental_days,p.amount AS amount_paid,
    (p.amount / (SELECT SUM(amount) FROM payment) * 100) AS percentage_spending
FROM rental r
JOIN customer c using(customer_id)
JOIN inventory i using(inventory_id)
JOIN film f using(film_id)
JOIN payment p using(rental_id);
select * from rental_details_view;
-- 17. Display the customers who paid 50% of their total rental costs within one day. 
SELECT c.customer_id,CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.amount) AS total_payment,DATEDIFF(MAX(r.rental_date), MIN(r.rental_date)) AS rental_duration,
    (SUM(p.amount) / DATEDIFF(MAX(r.rental_date), MIN(r.rental_date))) AS daily_payment,sum(p.amount)/2 
FROM customer c
JOIN rental r using(customer_id)
JOIN payment p using(rental_id)
GROUP BY c.customer_id, customer_name
HAVING daily_payment >=sum(p.amount)/2
    AND rental_duration = 1; # No one can Paid 50% of their total rental costs within one day