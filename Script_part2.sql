### Задание 1 ###

#Одним запросом получите информацию о магазине, в котором обслуживается более 300 покупателей, 
#и выведите в результат следующую информацию:

#фамилия и имя сотрудника из этого магазина;
#город нахождения магазина;
#количество пользователей, закреплённых в этом магазине.

#Вариант 1

SELECT  CONCAT(s.last_name, ' ', s.first_name) AS staff_name, ca.city, cc.count_customer 
FROM staff s
INNER JOIN 
  (SELECT a.address,  c.city, a.city_id, a.address_id  
   FROM address a
   JOIN city c ON c.city_id = a.city_id) ca
ON ca.address_id = s.address_id 
INNER JOIN store ON store.store_id = s.store_id
INNER JOIN 
  (SELECT COUNT(store_id) count_customer, store_id 
   FROM customer 
   GROUP BY store_id) cc
ON cc.store_id = s.store_id
WHERE cc.count_customer > 300; 

# Подзапросы
SELECT a.address,  c.city, a.city_id, a.address_id  
FROM address a
JOIN city c ON c.city_id = a.city_id;  

SELECT COUNT(store_id) count_customer, store_id 
FROM customer 
GROUP BY store_id;

#Вариант 2

SELECT  CONCAT(s.last_name, ' ', s.first_name) AS staff_name, c.city, COUNT(customer.customer_id)
FROM staff s
INNER JOIN address a ON  a.address_id = s.address_id 
INNER JOIN city c  ON  a.city_id  = c.city_id  
INNER JOIN store ON store.store_id = s.store_id
INNER JOIN customer  ON store.store_id = customer.store_id
GROUP BY staff_id 
HAVING  COUNT(customer.customer_id) > 300; 


###Задание 2###
#Получите количество фильмов, продолжительность которых больше средней продолжительности всех фильмов.

SELECT COUNT(f.title)   
FROM film f
WHERE  f.length > 
 (SELECT AVG(length) as avg_length
  FROM film); 

# Подзапросы
SELECT AVG(f.length) as avg_length
FROM film f


###Задание 3###
#Получите информацию, за какой месяц была получена наибольшая сумма платежей, 
# и добавьте информацию по количеству аренд за этот месяц.
SET lc_time_names = 'en_US'

SELECT t1.sum_month as 'месяц с наибольшей суммой платежей', t1.sum_amount, t2.sum_rental  
FROM 
(SELECT  DATE_FORMAT(payment_date, '%M %Y') as sum_month,  SUM(amount) as sum_amount
FROM payment
GROUP BY MDATE_FORMAT(payment_date, '%M %Y')) t1
JOIN 
(SELECT  DATE_FORMAT(rental_date, '%M %Y') as sum_month,  COUNT(rental_id)  as sum_rental
FROM rental 
GROUP BY DATE_FORMAT(rental_date, '%M %Y')) t2
ON t1.sum_month = t2.sum_month
ORDER BY t1.sum_amount DESC
LIMIT 1;

# Подзапросы


SELECT DATE_FORMAT(payment_date, '%M %Y') as sum_month,  SUM(amount) as sum_amount_pay
FROM payment
GROUP BY DATE_FORMAT(payment_date, '%M %Y');

SELECT  DATE_FORMAT(rental_date, '%M %Y') as sum_month,  COUNT(rental_id)  as sum_rental
FROM rental 
GROUP BY DATE_FORMAT(rental_date, '%M %Y');

### Упрощенный вариант задания 3

SELECT DATE_FORMAT(payment_date, '%M %Y') as 'месяц с наибольшей суммой платежей', SUM(amount), COUNT(rental_id)
FROM payment  
GROUP BY DATE_FORMAT(payment_date, '%M %Y')
ORDER BY SUM(amount) DESC
limit 1;

###Задание 4*
#Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». 
#Если количество продаж превышает 8000, 
#то значение в колонке будет «Да», иначе должно быть значение «Нет».

-- SELECT CONCAT(s.last_name, ' ', s.first_name) AS staff_name, COUNT(p.payment_id),
-- CASE
-- WHEN COUNT(p.payment_id) > 8000 THEN 'Да'
-- ELSE 'Нет'
-- END AS 'Премия'
-- FROM payment p
-- INNER JOIN staff s ON s.staff_id =  p.staff_id  
-- GROUP BY p.staff_id;

SELECT CONCAT(s.last_name, ' ', s.first_name) AS staff_name, COUNT(r.rental_id),
CASE
  WHEN COUNT(r.rental_id) > 8000 THEN 'Да'
  ELSE 'Нет'
END AS 'Премия'
FROM rental r 
INNER JOIN staff s ON s.staff_id =  r.staff_id  
GROUP BY r.staff_id;

###Задание 5*
#Найдите фильмы, которые ни разу не брали в аренду.

SELECT f.title 
FROM film f
LEFT JOIN inventory i ON i.film_id = f.film_id
LEFT JOIN rental r ON r.inventory_id = i.inventory_id
WHERE r.rental_id IS NULL AND i.inventory_id IS NULL;

