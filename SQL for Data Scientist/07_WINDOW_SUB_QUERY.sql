# 7.1
# 窗口函數 ROW_NUMBER
SELECT
	vendor_id,
    market_date,
    product_id,
    original_price,
    ROW_NUMBER() OVER (PARTITION BY vendor_id
		ORDER BY original_price DESC) AS price_rank
FROM farmers_market.vendor_inventory
ORDER BY vendor_id, original_price DESC;

# 將上面的查詢當作子查詢
SELECT * FROM
(
	SELECT
		vendor_id,
		market_date,
		product_id,
		original_price,
		ROW_NUMBER() OVER (PARTITION BY vendor_id
			ORDER BY original_price DESC) AS price_rank
	FROM farmers_market.vendor_inventory ORDER BY vendor_id
) AS x
WHERE x.price_rank = 1;

# 錯誤範例1
SELECT
	vendor_id,
    market_date,
    product_id,
    original_price,
    ROW_NUMBER() OVER (PARTITION BY vendor_id
		ORDER BY original_price DESC) AS price_rank
FROM farmers_market.vendor_inventory
WHERE price_rank = 1
ORDER BY vendor_id;

# 錯誤範例 2
SELECT
	vendor_id,
    market_date,
    product_id,
    original_price
FROM farmers_market.vendor_inventory
WHERE (ROW_NUMBER() OVER (PARTITION BY vendor_id
		ORDER BY original_price DESC) = 1)
ORDER BY vendor_id;

# 不分區排名
SELECT
	vendor_id,
    market_date,
    product_id,
    original_price,
    ROW_NUMBER() OVER (ORDER BY original_price DESC) AS price_rank
FROM farmers_market.vendor_inventory
ORDER BY price_rank;

# 7.2
# 窗口函數 RANK & DENSE RANK
# RANK()
SELECT
	vendor_id,
    market_date,
    product_id,
    original_price,
    RANK() OVER (ORDER BY original_price DESC) AS price_rank
FROM farmers_market.vendor_inventory
ORDER BY price_rank;

# DENSE_RANK()
SELECT
	vendor_id,
    market_date,
    product_id,
    original_price,
    DENSE_RANK() OVER (ORDER BY original_price DESC) AS price_rank
FROM farmers_market.vendor_inventory
ORDER BY price_rank;

# 7.3
# 窗口函數 NTILE
SELECT *
FROM (
	SELECT
		vendor_id,
		market_date,
		product_id,
		original_price,
		NTILE(10) OVER (ORDER BY original_price DESC)
			AS price_ntile
	FROM farmers_market.vendor_inventory
) AS x
WHERE x.price_ntile = 10;

# 7.4
# 聚合窗口函數
# 以AVG 聚合函數計算各分區的平均單價
SELECT *
FROM
(
	SELECT
		vendor_id,
		market_date,
		product_id,
		original_price,
		ROUND(AVG(original_price) OVER (PARTITION BY market_date
			ORDER BY market_date), 2) AS avg_by_market_date
	FROM farmers_market.vendor_inventory
) AS x
WHERE x.vendor_id = 8
  AND x.original_price > x.avg_by_market_date
ORDER BY x.market_date, x.original_price DESC;

# 以count 聚合函數計算各分區的項目數
SELECT
	vendor_id,
	market_date,
	product_id,
	original_price,
	COUNT(product_id) OVER (PARTITION BY market_date, vendor_id)
		AS vendor_product_count_per_market_date
FROM farmers_market.vendor_inventory
ORDER BY vendor_id, market_date, original_price DESC;

# 用SUM 聚合函數計算各分區的加總
SELECT
	customer_id,
	market_date,
    vendor_id,
	product_id,
	quantity * cost_to_customer_per_qty AS price,
	SUM(quantity * cost_to_customer_per_qty) OVER 
		(ORDER BY market_date, transaction_time, customer_id, product_id)
		AS running_total_purchases
FROM farmers_market.customer_purchases;

# 以顧客id分區
SELECT
	customer_id,
	market_date,
    vendor_id,
	product_id,
	quantity * cost_to_customer_per_qty AS price,
	SUM(quantity * cost_to_customer_per_qty) OVER 
		(PARTITION BY customer_id
         ORDER BY market_date, transaction_time, product_id)
		 AS customer_running_total_purchases
FROM farmers_market.customer_purchases;

# 有分區沒有排序
SELECT
	customer_id,
	market_date,
    vendor_id,
	product_id,
	quantity * cost_to_customer_per_qty AS price,
	SUM(quantity * cost_to_customer_per_qty) OVER 
		(PARTITION BY customer_id)
		 AS customer_running_total_purchases
FROM farmers_market.customer_purchases;

# 7.5
# 窗口函數 LAG & LEAD
# 由當前紀錄往後位移列數的LAG 函數
# 依市集日期查看各供應商當次與前次的攤位分配
SELECT
	market_date,
    vendor_id,
    booth_number,
    LAG(booth_number,1) OVER (PARTITION BY vendor_id
		ORDER BY market_date)
        AS previous_booth_number
FROM farmers_market.vendor_booth_assignments
ORDER BY market_date, vendor_id, booth_number;

# 找出2019-04-10 攤位有異動的供應商 (包含新進供應商)
SELECT * FROM
(
	SELECT
		market_date,
		vendor_id,
		booth_number,
		LAG(booth_number,1) OVER (PARTITION BY vendor_id
			ORDER BY market_date)
			AS previous_booth_number
	FROM farmers_market.vendor_booth_assignments
	ORDER BY market_date, vendor_id, booth_number
) AS x
WHERE x.market_date = '2019-04-10'
  AND ( x.booth_number <> x.previous_booth_number
  OR x.previous_booth_number is NULL);
  
# 比較本次與前次市集日期的總銷售額
SELECT
	market_date,
    SUM(quantity * cost_to_customer_per_qty) AS market_date_total_sales,
    LAG(SUM(quantity * cost_to_customer_per_qty),1) 
		OVER (ORDER BY market_date)
        AS previous_market_date_total_sales
FROM farmers_market.customer_purchases
GROUP BY market_date
ORDER BY market_date;

# 進一步比大小 並使用窗口命名功能
SELECT
	market_date,
    SUM(quantity * cost_to_customer_per_qty) AS market_date_total_sales,
    LAG(SUM(quantity * cost_to_customer_per_qty),1) 
		OVER w
        AS previous_market_date_total_sales,
	SUM(quantity * cost_to_customer_per_qty) -
	LAG(SUM(quantity * cost_to_customer_per_qty),1) 
		OVER w AS sales_growth
FROM farmers_market.customer_purchases
GROUP BY market_date
WINDOW w
	AS (ORDER BY market_date)
ORDER BY market_date;

# 由當前紀錄往前位移列數的LEAD函數 並使用子查詢
SELECT
	market_date,
    market_date_total_sales,
    LEAD(market_date_total_sales, 1) OVER
		(ORDER BY market_date) AS next_market_date_total_sales,
	LEAD(market_date_total_sales, 1) OVER (ORDER BY market_date) - 
		market_date_total_sales AS sales_growth
FROM
(
	SELECT
		market_date,
        SUM(quantity * cost_to_customer_per_qty) 
			AS market_date_total_sales
	FROM farmers_market.customer_purchases
    GROUP BY market_date
) AS sales
ORDER BY market_date;

# practice
# 依顧客來消費的次數編號(同個日期算一次)
# RANK() 需要先GROUP BY 因為編碼會跳號
SELECT 
	customer_id,
    market_date,
	RANK() OVER 
		(PARTITION BY customer_id ORDER BY market_date)
		AS visit_number
FROM farmers_market.customer_purchases
GROUP BY customer_id, market_date
ORDER BY customer_id, market_date;

SELECT
	customer_id,
    market_date,
	DENSE_RANK() OVER 
		(PARTITION BY customer_id ORDER BY market_date)
		AS visit_number
FROM farmers_market.customer_purchases
ORDER BY customer_id, market_date;

# 倒轉編號 最近一次造訪為1 為子查詢 外部查詢只留最近一次的造訪紀錄
SELECT * FROM
(
	SELECT 
		customer_id,
		market_date,
		RANK() OVER 
			(PARTITION BY customer_id ORDER BY market_date DESC)
			AS visit_number
	FROM farmers_market.customer_purchases
    GROUP BY customer_id, market_date
) AS x
WHERE x.visit_number = 1;

SELECT * FROM
(
	SELECT
		customer_id,
		market_date,
		DENSE_RANK() OVER 
			(PARTITION BY customer_id ORDER BY market_date DESC)
			AS visit_number
	FROM farmers_market.customer_purchases
) AS x
WHERE x.visit_number = 1;

# 使用COUNT 窗口函數 計算同一個顧客購買同一個產品的次數
SELECT 
	*,
	COUNT(product_id) OVER 
		(PARTITION BY customer_id, product_id)
		AS product_purchase_count
FROM farmers_market.customer_purchases
ORDER BY customer_id, product_id, market_date;

# 比較本次與前次市集日期的總銷售額 使用LEAD
SELECT
	market_date,
    SUM(quantity * cost_to_customer_per_qty) AS market_date_total_sales,
    LEAD(SUM(quantity * cost_to_customer_per_qty),1) 
		OVER (ORDER BY market_date DESC)
        AS previous_market_date_total_sales
FROM farmers_market.customer_purchases
GROUP BY market_date
ORDER BY market_date;