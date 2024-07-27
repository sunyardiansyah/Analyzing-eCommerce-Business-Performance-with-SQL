--Membuat tabel yang berisi informasi pendapatan/revenue perusahaan total untuk masing-masing tahun 
--(Hint: Revenue adalah harga barang dan juga biaya kirim. 
--Pastikan juga melakukan filtering terhadap order status yang tepat untuk menghitung pendapatan)

SELECT
	EXTRACT(YEAR FROM ord.order_purchase_timestamp ) AS year,
	SUM(oi.price + op.payment_value) AS revenue
FROM 
	orders ord
LEFT JOIN
	order_items oi ON ord.order_id = oi.order_id
LEFT JOIN
	order_payments op ON ord.order_id = op.order_id
WHERE 
	ord.order_status = 'delivered'
GROUP BY
	EXTRACT(YEAR FROM ord.order_purchase_timestamp)
ORDER BY
	year;

-- Membuat tabel yang berisi informasi jumlah cancel order total untuk masing-masing tahun 
-- (Hint: Perhatikan filtering terhadap order status yang tepat untuk menghitung jumlah cancel order)
SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
	COUNT(*) AS jumlah_canceled
FROM 
	orders
WHERE 
	order_status = 'canceled'
GROUP BY
	EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY
	year;

-- Membuat tabel yang berisi nama kategori produk yang memberikan pendapatan total tertinggi untuk masing-masing tahun 
-- (Hint: Perhatikan penggunaan window function dan juga filtering yang dilakukan)

SELECT 
	year,
	product_category_name
FROM
(SELECT
	EXTRACT(YEAR FROM ord.order_purchase_timestamp) AS year,
	pr.product_category_name,
	SUM(oi.price + op.payment_value) AS revenue,
	ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM ord.order_purchase_timestamp) ORDER BY SUM(oi.price + op.payment_value) DESC) AS rnk
FROM 
	orders ord
LEFT JOIN
	order_items oi ON ord.order_id = oi.order_id
LEFT JOIN
	order_payments op ON ord.order_id = op.order_id
LEFT JOIN
	product pr ON oi.product_id = pr.product_id 
WHERE 
	ord.order_status = 'delivered'
GROUP BY
	EXTRACT(YEAR FROM ord.order_purchase_timestamp),
	pr.product_category_name
ORDER BY
	year)
WHERE 
	rnk = 1;


-- Membuat tabel yang berisi nama kategori produk yang memiliki jumlah cancel order terbanyak 
-- untuk masing-masing tahun (Hint: Perhatikan penggunaan window function dan juga filtering yang dilakukan)
SELECT 
	year,
	COALESCE(product_category_name, 'unknown_category') AS product_category,
	jumlah_canceled
FROM
(SELECT
	EXTRACT(YEAR FROM ord.order_purchase_timestamp) AS year,
	product_category_name,
	COUNT(ord.*) AS jumlah_canceled,
	ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM ord.order_purchase_timestamp) ORDER BY COUNT(ord.*) DESC) AS rnk
FROM 
	orders ord
LEFT JOIN
	order_items oi ON ord.order_id = oi.order_id
LEFT JOIN
	product pr ON oi.product_id = pr.product_id 
WHERE 
	order_status = 'canceled'
GROUP BY
	EXTRACT(YEAR FROM order_purchase_timestamp),
	product_category_name
ORDER BY
	year)
WHERE 
	rnk = 1;


-- Menggabungkan Nomor 1 sampai 4
WITH 
revenue_by_years AS (
	SELECT
		EXTRACT(YEAR FROM ord.order_purchase_timestamp ) AS year,
		SUM(oi.price + op.payment_value) AS revenue
	FROM 
		orders ord
	LEFT JOIN
		order_items oi ON ord.order_id = oi.order_id
	LEFT JOIN
		order_payments op ON ord.order_id = op.order_id
	WHERE 
		ord.order_status = 'delivered'
	GROUP BY
		EXTRACT(YEAR FROM ord.order_purchase_timestamp)
	ORDER BY
		year

),
canceled_by_years AS (
	SELECT
		EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
		COUNT(*) AS jumlah_canceled
	FROM 
		orders
	WHERE 
		order_status = 'canceled'
	GROUP BY
		EXTRACT(YEAR FROM order_purchase_timestamp)
	ORDER BY
		year
),
category_by_years AS (
	SELECT 
		year,
		product_category_name
	FROM
	(SELECT
		EXTRACT(YEAR FROM ord.order_purchase_timestamp) AS year,
		pr.product_category_name,
		SUM(oi.price + op.payment_value) AS revenue,
		ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM ord.order_purchase_timestamp) ORDER BY SUM(oi.price + op.payment_value) DESC) AS rnk
	FROM 
		orders ord
	LEFT JOIN
		order_items oi ON ord.order_id = oi.order_id
	LEFT JOIN
		order_payments op ON ord.order_id = op.order_id
	LEFT JOIN
		product pr ON oi.product_id = pr.product_id 
	WHERE 
		ord.order_status = 'delivered'
	GROUP BY
		EXTRACT(YEAR FROM ord.order_purchase_timestamp),
		pr.product_category_name
	ORDER BY
		year)
	WHERE 
		rnk = 1
),
canceled_category_by_years AS (
	SELECT 
		year,
		COALESCE(product_category_name, 'unknown_category') AS product_category,
		jumlah_canceled
	FROM
	(SELECT
		EXTRACT(YEAR FROM ord.order_purchase_timestamp) AS year,
		product_category_name,
		COUNT(ord.*) AS jumlah_canceled,
		ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM ord.order_purchase_timestamp) ORDER BY COUNT(ord.*) DESC) AS rnk
	FROM 
		orders ord
	LEFT JOIN
		order_items oi ON ord.order_id = oi.order_id
	LEFT JOIN
		product pr ON oi.product_id = pr.product_id 
	WHERE 
		order_status = 'canceled'
	GROUP BY
		EXTRACT(YEAR FROM order_purchase_timestamp),
		product_category_name
	ORDER BY
		year)
	WHERE 
		rnk = 1
)
SELECT 
	ry.year,
	ry.revenue,
	cy.jumlah_canceled AS number_of_cancels,
	caty.product_category_name AS best_selling_category,
	ccy.product_category AS most_canceled_category
FROM
	revenue_by_years ry
FULL OUTER JOIN
	canceled_by_years cy ON ry.year = cy.year
FULL OUTER JOIN
	category_by_years caty ON cy.year = caty.year
FULL OUTER JOIN
	canceled_category_by_years ccy ON caty.year = ccy.year
