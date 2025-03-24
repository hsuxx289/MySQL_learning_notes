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

# 單列欄位資料運算與別名
SELECT 
		market_date,
		customer_id,
        vendor_id,
        quantity * cost_to_customer_per_qty AS price
FROM farmers_market.customer_purchases
ORDER BY market_date
LIMIT 10;