# 3.1
# 篩選符合條件資料
SELECT 
	market_date,
    customer_id,
    vendor_id,
    product_id,
    quantity,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS price
FROM farmers_market.customer_purchases
WHERE customer_id = 4
ORDER BY market_date, vendor_id, product_id
LIMIT 5;

# 3.2
# 多重條件篩選
# OR
SELECT 
	market_date,
    customer_id,
    vendor_id,
    product_id,
    quantity,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS price
FROM farmers_market.customer_purchases
WHERE customer_id = 4 OR customer_id = 6
ORDER BY market_date, customer_id, vendor_id, product_id
LIMIT 5;

# AND
SELECT 
	market_date,
    customer_id,
    vendor_id,
    product_id,
    quantity,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS price
FROM farmers_market.customer_purchases
WHERE customer_id > 3 AND customer_id <= 6
ORDER BY market_date, customer_id, vendor_id, product_id
LIMIT 5;

# 多重算符
SELECT
	product_id,
    product_name
FROM farmers_market.product
WHERE
	product_id = 10
    OR (product_id > 3
    AND product_id < 8);
    
# 3.3
# 多個欄位條件篩選
SELECT
	market_date,
    customer_id,
    vendor_id,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS price
FROM farmers_market.customer_purchases
WHERE
	customer_id = 4 AND vendor_id = 7
LIMIT 5;

# 篩選字串
SELECT
	customer_id,
    customer_first_name,
    customer_last_name
FROM farmers_market.customer
WHERE
	customer_first_name = 'Carlos'
    OR customer_last_name = 'Diaz';
    
# 篩選日期
SELECT * 
FROM farmers_market.vendor_booth_assignments
WHERE
	vendor_id = 9
    AND market_date <= '2019-08-09'
ORDER BY market_date
LIMIT 5;

# 3.4
# 用於篩選的關鍵字
# BETWEEN
SELECT * 
FROM farmers_market.vendor_booth_assignments
WHERE
	vendor_id = 7
    AND market_date BETWEEN '2019-04-03' AND '2019-08-09'
ORDER BY market_date
LIMIT 5;

# IN
SELECT
	customer_id,
    customer_first_name,
    customer_last_name
FROM farmers_market.customer
WHERE
	customer_last_name IN ('Diaz', 'Edwards', 'Wilson')
ORDER BY customer_last_name, customer_first_name
LIMIT 5;

# LIKE
SELECT
	customer_id,
    customer_first_name,
    customer_last_name
FROM farmers_market.customer
WHERE
	customer_first_name LIKE 'Jer%';
    
# REGEXP
SELECT
	customer_id,
    customer_first_name,
    customer_last_name
FROM farmers_market.customer
WHERE
	customer_first_name REGEXP '^[abc]';

# IS NULL
SELECT *
FROM farmers_market.product
WHERE product_size IS NULL;

# TRIM()
SELECT *
FROM farmers_market.product
WHERE 
	product_size IS NULL
    OR TRIM(product_size);
    
# NULL (其實後面三行不寫結果也一樣)
SELECT
	market_year,
    market_week,
    market_max_temp
FROM farmers_market.market_date_info
WHERE
	(market_year = 2019 OR market_year = 2020)
    AND market_week = 11
    AND (market_max_temp > 50
		OR market_max_temp <=50
        OR market_max_temp IS NULL);
        
# 3.5
# 透過子查詢做篩選
# 先找出下雨日期
SELECT market_date
FROM farmers_market.market_date_info
WHERE market_date >= '2019-07-01'
	AND market_date <= '2019-12-31'
    AND market_rain_flag = 1;
    
# 計算上述日期中的交易額
SELECT 
	market_date,
    customer_id,
    vendor_id,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS price
FROM farmers_market.customer_purchases
WHERE
	market_date IN
		(
			SELECT market_date
			FROM farmers_market.market_date_info
			WHERE market_date >= '2019-07-01'
				AND market_date <= '2019-12-31'
				AND market_rain_flag = 1
		)
ORDER BY vendor_id;

# practice
# 回傳所有customer_id 為 4 與 9 的購買紀錄
SELECT *
FROM farmers_market.customer_purchases
WHERE customer_id IN (4, 9);
    
# 比照上面的方式查詢8-10 但分別用AND 跟 BETWEEN 兩種方式
SELECT *
FROM farmers_market.customer_purchases
WHERE customer_id >= 8
	AND customer_id <=10;
    
SELECT *
FROM farmers_market.customer_purchases
WHERE customer_id BETWEEN 8 AND 10;

# 用兩種方法改寫3.5 的例題 但改查詢沒下雨的日期
# 改flag欄位值
SELECT 
	market_date,
    customer_id,
    vendor_id,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS price
FROM farmers_market.customer_purchases
WHERE
	market_date IN
		(
			SELECT market_date
			FROM farmers_market.market_date_info
			WHERE market_date >= '2019-07-01'
				AND market_date <= '2019-12-31'
				AND market_rain_flag = 0
		)
ORDER BY vendor_id;

# 改not in
SELECT 
	market_date,
    customer_id,
    vendor_id,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS price
FROM farmers_market.customer_purchases
WHERE
	market_date NOT IN
		(
			SELECT market_date
			FROM farmers_market.market_date_info
			WHERE market_date >= '2019-07-01'
				AND market_date <= '2019-12-31'
				AND market_rain_flag = 1
		)
ORDER BY vendor_id;