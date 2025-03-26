# 2-3
# 不use database 就選取到表格的方法
SELECT *
FROM farmers_market.product;

# 前5行 用於大型表格
SELECT *
FROM farmers_market.product
LIMIT 5;

# 指定欄位
SELECT market_date, vendor_id, booth_number
FROM farmers_market.vendor_booth_assignments
LIMIT 5;

# 2-4
# 依字母排序 (預設為升冪且 NULL 會在前面)
SELECT product_id, product_name
FROM farmers_market.product
ORDER BY product_name
LIMIT 5;

# 依數字降冪排序
SELECT product_id, product_name
FROM farmers_market.product
ORDER BY product_id DESC
LIMIT 5;

# 排序兩個欄位(先排好1 再排2)
SELECT market_date, vendor_id, booth_number
FROM farmers_market.vendor_booth_assignments
ORDER BY market_date, vendor_id
LIMIT 12;

# 2-5
# 單列欄位資料運算與別名
SELECT 
	market_date,
	customer_id,
	vendor_id,
	quantity * cost_to_customer_per_qty AS price
FROM farmers_market.customer_purchases
ORDER BY market_date
LIMIT 10;

# 2-6
# 四捨五入的函數
SELECT 
	market_date,
	customer_id,
	vendor_id,
	ROUND(quantity * cost_to_customer_per_qty, 2) AS price
FROM farmers_market.customer_purchases
ORDER BY market_date
LIMIT 10;

# 2-7 
# 連接字串的函數
SELECT
	customer_id,
	CONCAT(customer_first_name, " ", customer_last_name)
		AS customer_name
FROM farmers_market.customer
ORDER BY customer_last_name, customer_first_name
LIMIT 5;

# 函數裡的函數
SELECT
	customer_id,
    UPPER(CONCAT(customer_last_name, ", ", customer_first_name))
		AS customer_name
FROM farmers_market.customer
ORDER BY customer_last_name, customer_first_name
LIMIT 5;

# 函數嵌套計算
SELECT ROUND(AVG(SUM(price)), 2) AS avg_price
FROM sales
GROUP BY product_id;

# 函數嵌套作為參數
SELECT CONCAT(UPPER(LEFT(first_name, 1)),
	LOWER(SUBSTRING(first_name, 2))) AS formatted_name
FROM customers;

# practice
# 回傳customer 表格中的所有欄位資料
SELECT * FROM farmers_market.customer;

# 只回傳customer 的前10筆資料 以last name 然後 first name 排序
SELECT *
FROM farmers_market.customer
ORDER BY customer_last_name, customer_first_name
LIMIT 10;

# 列出id first name 欄位 並以first name 排序
SELECT customer_id, customer_first_name
FROM farmers_market.customer 
ORDER BY customer_first_name;