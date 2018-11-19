USE sakila;

-- 1a. Display the first and last names of all actors from the table actor. --
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. --
SELECT UPPER(CONCAT(first_name,' ', last_name)) AS actor_name FROM actor;




-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information? --
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN --
SELECT * FROM actor WHERE
last_name LIKE '%G%'
AND
last_name LIKE '%E%'
AND
last_name LIKE '%N%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order --
SELECT last_name, first_name FROM actor WHERE
last_name LIKE '%L%'
AND
last_name LIKE '%I%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China --
SELECT country_id, country FROM country WHERE
country IN ('AFGHANISTAN', 'BANGLADESH', 'CHINA');




-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant). --
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column. --
ALTER TABLE actor
DROP COLUMN description;




-- 4a. List the last names of actors, as well as how many actors have that last name. --
SELECT last_name, COUNT(*) AS identical_counts FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors --
SELECT last_name, COUNT(*) AS identical_counts FROM actor
GROUP BY last_name
HAVING identical_counts > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record. --
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO.
-- It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. --
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";




-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? --
SHOW CREATE TABLE address;




-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address --
SELECT first_name, last_name, address FROM staff
JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. --
SELECT first_name, last_name, SUM(amount) AS rung_money FROM staff
JOIN payment ON staff.staff_id = payment.staff_id
AND payment_date LIKE '2005-08%'
GROUP BY payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join. --
SELECT title, COUNT(actor_id) FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system? --
SELECT title, COUNT(inventory_id) FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
WHERE title = 'HUNCHBACK IMPOSSIBLE';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name --
SELECT last_name, first_name, SUM(amount) FROM payment
INNER JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY last_name;




-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. --
SELECT film_id, title FROM film WHERE
title LIKE 'K%'
OR
title LIKE 'Q%'
AND language_id = '1';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip. --
SELECT last_name, first_name FROM actor WHERE
actor_id IN
	(SELECT actor_id FROM film_actor WHERE film_id IN
		(SELECT film_id FROM film WHERE title = 'ALONE TRIP'));
        
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information. --
SELECT country, last_name, first_name, email FROM country
JOIN customer
ON country.country_id = customer.customer_id WHERE
country = 'CANADA';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films. --
SELECT title FROM film_list WHERE
category = 'FAMILY';

-- 7e. Display the most frequently rented movies in descending order. --
SELECT inventory.inventory_id, film.title, COUNT(rental_id) AS times_rented FROM rental
JOIN inventory
ON (rental.inventory_id = inventory.inventory_id)
JOIN film
ON (inventory.film_id = film.film_id)
GROUP BY film.title
ORDER BY COUNT(rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in. --
SELECT store.store_id, SUM(amount) AS dollar_revenue FROM payment
JOIN rental
ON payment.rental_id = rental.rental_id
JOIN inventory
ON inventory.inventory_id = rental.inventory_id
JOIN store
ON store.store_id = inventory.store_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country. --
SELECT store.store_id, city.city, country.country FROM store
JOIN address
ON store.address_id = address.address_id
JOIN city
ON city.city_id = address.city_id
JOIN country
ON country.country_id = city.country_id
GROUP BY store.store_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) --
SELECT category.name AS genre, SUM(payment.amount) AS gross_revenue FROM category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY genre
ORDER BY SUM(payment.amount)
DESC
LIMIT 5;




-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view. --
CREATE VIEW Popular_Genres AS
SELECT category.name AS genre, SUM(payment.amount) AS gross_revenue FROM category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY genre
ORDER BY SUM(payment.amount)
DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a? --
SELECT * FROM Popular_Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it. --
DROP VIEW Popular_Genres;