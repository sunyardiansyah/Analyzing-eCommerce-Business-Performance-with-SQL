-- Menampilkan jumlah penggunaan masing-masing tipe pembayaran secara all time diurutkan dari yang terfavorit 
-- (Hint: Perhatikan struktur (kolom-kolom apa saja) dari tabel akhir yang ingin didapatkan)
SELECT
	COALESCE(payment_type, 'unknown') AS payment_type,
	COUNT(*) AS number_of_used
FROM (
	SELECT
		ord.order_id,
		op.payment_type
	FROM
		orders ord
	LEFT JOIN
		order_payments op ON ord.order_id = op.order_id
)
GROUP BY
	payment_type
ORDER BY
	COUNT(*) DESC

-- Menampilkan detail informasi jumlah penggunaan masing-masing tipe pembayaran untuk setiap tahun 
-- (Hint: Perhatikan struktur (kolom-kolom apa saja) dari tabel akhir yang ingin didapatkan)

SELECT
	COALESCE(payment_type, 'unknown') AS payment_type,
	year,
	COUNT(*) AS amount_used,
	CASE
		WHEN payment_type = 'credit_card' THEN 1
		WHEN payment_type = 'boleto' THEN 2
		WHEN payment_type = 'voucher' THEN 3
		WHEN payment_type = 'debit_card' THEN 4
		WHEN payment_type = 'not_defined' THEN 5
		ELSE 6
	END AS popular_number
FROM (
	SELECT
		ord.order_id,
		op.payment_type,
		EXTRACT(YEAR FROM ord.order_purchase_timestamp) AS year
	FROM
		orders ord
	LEFT JOIN
		order_payments op ON ord.order_id = op.order_id
)
GROUP BY
	payment_type,
	year
ORDER BY
	4, 2

