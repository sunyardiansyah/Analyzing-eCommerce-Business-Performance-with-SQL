-- Merubah type data geolocation_zip_code_prefix menjadi Varchar
ALTER TABLE geolocation
ALTER COLUMN geolocation_zip_code_prefix TYPE VARCHAR USING geolocation_zip_code_prefix::VARCHAR;

-- Menambahkan kolom baru zipcode_prefix
ALTER TABLE geolocation
ADD COLUMN zipcode_prefix VARCHAR(3);

-- Mengisi kolom zipcode_prefix dengan tiga karakter pertama dari geolocation_zip_code_prefix
UPDATE geolocation
SET zipcode_prefix = SUBSTRING(geolocation_zip_code_prefix FROM 1 FOR 3);

-- Membuat tabel geolocation_edit
CREATE TABLE geolocation_edit as (
	SELECT DISTINCT ON (zipcode_prefix) *
	FROM geolocation;
)

-- Menambahkan zipcode_prefix dan Menghubungkan Foreign Key (zipcode_prefix) 
-- dari Tabel geolocation_edit ke Tabel Sellers dan Customers

-- Pada Tabel Customers
-- Menambah Kolom zipcode_prefix
ALTER TABLE customers
ALTER COLUMN customer_zip_code_prefix TYPE VARCHAR USING customer_zip_code_prefix::VARCHAR;

-- Menambahkan kolom baru zipcode_prefix
ALTER TABLE customers
ADD COLUMN zipcode_prefix VARCHAR(3);

-- Mengisi kolom zipcode_prefix dengan tiga karakter pertama dari geolocation_zip_code_prefix
UPDATE customers
SET zipcode_prefix = SUBSTRING(customer_zip_code_prefix FROM 1 FOR 3);

-- Menghubungkan Foreign Key
ALTER TABLE customers
ADD CONSTRAINT fk_zipcode_prefix
FOREIGN KEY (zipcode_prefix)
REFERENCES geolocation_edit (zipcode_prefix);


-- Pada Tabel Customers
-- Menambah Kolom zipcode_prefix
ALTER TABLE sellers
ALTER COLUMN seller_zip_code_prefix TYPE VARCHAR USING seller_zip_code_prefix::VARCHAR;

-- Menambahkan kolom baru zipcode_prefix
ALTER TABLE sellers
ADD COLUMN zipcode_prefix VARCHAR(3);

-- Mengisi kolom zipcode_prefix dengan tiga karakter pertama dari geolocation_zip_code_prefix
UPDATE sellers
SET zipcode_prefix = SUBSTRING(seller_zip_code_prefix FROM 1 FOR 3);

-- Menghubungkan Foreign Key
ALTER TABLE sellers
ADD CONSTRAINT fk_zipcode_prefix
FOREIGN KEY (zipcode_prefix)
REFERENCES geolocation_edit (zipcode_prefix);
