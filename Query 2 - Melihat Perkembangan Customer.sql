-- Menampilkan rata-rata jumlah customer aktif bulanan (monthly active user) 
-- untuk setiap tahun (Hint: Perhatikan kesesuaian format tanggal)

SELECT 
	o.year,
	ROUND(SUM(o.entry_count)/COUNT(o.month)) AS rata_rata_bulan
FROM
(SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    COUNT(*) AS entry_count
FROM
    orders
GROUP BY
    EXTRACT(MONTH FROM order_purchase_timestamp),
    EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY
    year) AS o
GROUP BY
	o.year;
	
-- Menampilkan jumlah customer baru pada masing-masing tahun 
-- (Hint: Pelanggan baru adalah pelanggan yang melakukan order pertama kali)

SELECT 
	EXTRACT(YEAR FROM first_order_date) AS order_year, 
	COUNT(customer_id) AS new_customers
FROM
	(SELECT 
	 	customer_id, 
	 	MIN(order_purchase_timestamp) AS first_order_date	
	FROM orders
	GROUP BY customer_id)
GROUP BY order_year 
ORDER BY order_year;

-- Menampilkan jumlah customer yang melakukan pembelian lebih dari satu kali (repeat order) 
-- pada masing-masing tahun (Hint: Pelanggan yang melakukan repeat order adalah pelanggan 
-- yang melakukan order lebih dari 1 kali)

WITH repeat_customers AS (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
),
orders_with_year AS (
    SELECT customer_id, EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year
    FROM orders
)
SELECT order_year, COUNT(DISTINCT customer_id) AS repeat_customers
FROM orders_with_year
WHERE customer_id IN (SELECT customer_id FROM repeat_customers)
GROUP BY order_year
ORDER BY order_year;

-- Menampilkan rata-rata jumlah order yang dilakukan customer untuk masing-masing tahun 
--(Hint: Hitung frekuensi order (berapa kali order) untuk masing-masing customer terlebih dahulu)
WITH customer_orders_per_year AS (
    SELECT 
		customer_id, 
		EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year, 
		COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id, order_year
)
SELECT 
	order_year, 
	ROUND(AVG(order_count)) AS average_order_count
FROM customer_orders_per_year
GROUP BY order_year
ORDER BY order_year;
