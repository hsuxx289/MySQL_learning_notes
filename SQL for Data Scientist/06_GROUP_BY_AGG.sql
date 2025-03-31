# 6.1
# 將資料分組的GROUP BY 子句
SELECT
	market_date,
    customer_id
FROM farmers_market.customer_purchases
GROUP BY market_date, customer_id
ORDER BY market_date, customer_id;

# 6.2
# 查詢分組與聚合資料
# 計算每個顧客有幾筆購買紀錄
SELECT
	market_date,
    customer_id,
    COUNT(*) AS items_purchased
FROM farmers_market.customer_purchases
GROUP BY market_date, customer_id
ORDER BY market_date, customer_id;

# 計算每個顧客購買的產品數量
SELECT
	market_date,
    customer_id,
    SUM(quantity) AS items_purchased
FROM farmers_market.customer_purchases
GROUP BY market_date, customer_id
ORDER BY market_date, customer_id;

# 改計算客戶買了幾種不同的產品
SELECT
	market_date,
    customer_id,
    COUNT(DISTINCT product_id) AS different_products_purchased
FROM farmers_market.customer_purchases
GROUP BY market_date, customer_id
ORDER BY market_date, customer_id
LIMIT 10;

# 6.3
# 在聚合函數中放入算式
# 計算3號顧客在每一個market_date 的總消費額
SELECT
	customer_id,
    market_date,
    SUM(quantity * cost_to_customer_per_qty) AS total_spent
FROM farmers_market.customer_purchases
WHERE
	customer_id = 3
GROUP BY market_date
ORDER BY market_date;

# 計算3號顧客不分日期 在個別供應商的消費額
SELECT
	customer_id,
	vendor_id,
    SUM(quantity * cost_to_customer_per_qty) AS total_spent
FROM farmers_market.customer_purchases
WHERE 
	customer_id = 3
GROUP BY vendor_id
ORDER BY vendor_id;

# 每一位顧客不限日期 不限供應商的總消費額
SELECT
	customer_id,
    SUM(quantity * cost_to_customer_per_qty) AS total_spent
FROM farmers_market.customer_purchases
GROUP BY customer_id
ORDER BY customer_id;

# 連結多個表格的分組與聚合
# 先連結表格檢查內容
SELECT
	c.customer_first_name,
    c.customer_last_name,
    cp.customer_id,
    v.vendor_name,
    cp.vendor_id,
    cp.quantity * cp.cost_to_customer_per_qty AS price
FROM farmers_market.customer AS c
	LEFT JOIN farmers_market.customer_purchases AS cp
		ON c.customer_id = cp.customer_id
	LEFT JOIN farmers_market.vendor AS v
		on cp.vendor_id = v.vendor_id
WHERE cp.customer_id = 3
ORDER BY cp.customer_id, cp.vendor_id
LIMIT 5;

# 確認無誤後進行分組聚合
# 計算3號顧客不分日期 在個別供應商的消費額 但這次包含顧客與供應商資訊
SELECT
	c.customer_first_name,
    c.customer_last_name,
    cp.customer_id,
    v.vendor_name,
    cp.vendor_id,
    ROUND(SUM(cp.quantity * cp.cost_to_customer_per_qty),2) AS price
FROM farmers_market.customer AS c
	LEFT JOIN farmers_market.customer_purchases AS cp
		ON c.customer_id = cp.customer_id
	LEFT JOIN farmers_market.vendor AS v
		on cp.vendor_id = v.vendor_id
WHERE cp.customer_id = 3
GROUP BY 
	c.customer_first_name,
    c.customer_last_name,
    cp.customer_id,
    v.vendor_name,
    cp.vendor_id
ORDER BY cp.customer_id, cp.vendor_id;

# 條件改成查詢7號供應商的話
SELECT
	c.customer_first_name,
    c.customer_last_name,
    cp.customer_id,
    v.vendor_name,
    cp.vendor_id,
    ROUND(SUM(cp.quantity * cp.cost_to_customer_per_qty),2) AS price
FROM farmers_market.customer AS c
	LEFT JOIN farmers_market.customer_purchases AS cp
		ON c.customer_id = cp.customer_id
	LEFT JOIN farmers_market.vendor AS v
		on cp.vendor_id = v.vendor_id
WHERE cp.vendor_id = 7
GROUP BY 
	c.customer_first_name,
    c.customer_last_name,
    cp.customer_id,
    v.vendor_name,
    cp.vendor_id
ORDER BY cp.customer_id, cp.vendor_id
LIMIT 5;

# 6.4
# 挑出最大與最小值的MAX()和MIN()
# 不限類別查出最高與最低價商品
SELECT
	MAX(original_price) AS maximum_price,
    MIN(original_price) AS minimun_price
FROM farmers_market.vendor_inventory;

# 找出各產品類別的最高與最低價
SELECT
	pc.product_category_name,
    p.product_category_id,
    MAX(original_price) AS maximum_price,
    MIN(original_price) AS minimun_price
FROM farmers_market.vendor_inventory AS vi
	INNER JOIN farmers_market.product AS p
		ON vi.product_id = p.product_id
	INNER JOIN farmers_market.product_category as pc
		ON p.product_category_id = pc.product_category_id
GROUP BY pc.product_category_name, p.product_category_id;

# 查詢個別日期供應了幾種商品 (不同供應商的商品就視為不同種)
SELECT
	market_date,
    COUNT(product_id) AS product_count
FROM farmers_market.vendor_inventory
GROUP BY market_date
ORDER BY market_date 
LIMIT 10;

# 查詢特定日期間 各供應商帶來多少種不同的產品
SELECT
	vendor_id,
    COUNT(DISTINCT product_id) AS different_product_offered
FROM farmers_market.vendor_inventory
WHERE market_date BETWEEN '2019-04-03' AND '2019-06-30'
GROUP BY vendor_id
ORDER BY vendor_id;

# 6.6 
# 計算平均值的AVG()
# 查詢特定日期間 各供應商帶來多少種不同的產品 以及平均價格
# 錯誤範例 (沒有考慮到數量 只用價格去平均)
SELECT
	vendor_id,
    COUNT(DISTINCT product_id) AS different_product_offered,
    AVG(original_price) AS average_product_price
FROM farmers_market.vendor_inventory
WHERE market_date BETWEEN '2019-04-03' AND '2019-06-30'
GROUP BY vendor_id
ORDER BY vendor_id;

# 正確範例 (沒有用到AVG())
SELECT
	vendor_id,
    COUNT(DISTINCT product_id) AS different_product_offered,
    SUM(quantity * original_price) AS value_of_inventory,
    SUM(quantity) AS inventory_item_count,
    ROUND(SUM(quantity * original_price) / SUM(quantity), 2)
		AS average_item_price
FROM farmers_market.vendor_inventory
WHERE market_date BETWEEN '2019-04-03' AND '2019-06-30'
GROUP BY vendor_id
ORDER BY vendor_id;

# 6.7
# 用HAVING 子句篩選分組後的資料
# 查詢特定日期間 各供應商帶來多少種不同的產品 以及平均價格 產品數大於100
SELECT
	vendor_id,
    COUNT(DISTINCT product_id) AS different_product_offered,
    SUM(quantity * original_price) AS value_of_inventory,
    SUM(quantity) AS inventory_item_count,
    ROUND(SUM(quantity * original_price) / SUM(quantity), 2)
		AS average_item_price
FROM farmers_market.vendor_inventory
WHERE market_date BETWEEN '2019-04-03' AND '2019-06-30'
GROUP BY vendor_id
HAVING inventory_item_count >= 100
ORDER BY vendor_id;

# 6.8
# 在聚合函數中使用CASE 語法
# 依照不同單位 進行加總
SELECT
	cp.market_date,
    cp.customer_id,
    SUM(CASE WHEN product_qty_type = 'lbs'
			 THEN quantity ELSE 0 END) AS quantity_lbs,
	SUM(CASE WHEN product_qty_type = 'unit'
			 THEN quantity ELSE 0 END) AS quantity_unit,
	SUM(CASE WHEN product_qty_type NOT IN ('lbs', 'unit')
			 THEN quantity ELSE 0 END) AS quantity_other
FROM farmers_market.customer_purchases AS cp
	 INNER JOIN farmers_market.product AS p
		   ON cp.product_id = p.product_id
GROUP BY market_date, customer_id
ORDER BY market_date, customer_id
LIMIT 10;

# practice
# 查詢每個供應商在農夫市集共租了幾次攤位
SELECT
	vendor_id,
    COUNT(*) AS count_of_booth_assignments
FROM farmers_market.vendor_booth_assignments
GROUP BY vendor_id
ORDER BY vendor_id;

# 查詢 Fresh Fruits & Vegetables 類別中的各種產品名稱 最早及最晚可購買日期
SELECT
	pc.product_category_name,
    p.product_name,
    MIN(vi.market_date) AS first_date_available,
    MAX(vi.market_date) AS last_date_available
FROM farmers_market.vendor_inventory AS vi
	 LEFT JOIN farmers_market.product AS p
		  ON vi.product_id = p.product_id
	 LEFT JOIN farmers_market.product_category AS pc
		  ON p.product_category_id = pc.product_category_id
WHERE pc.product_category_id = 1
GROUP BY pc.product_category_name, p.product_name;

# 查詢消費超過$50的顧客 依姓氏名字
SELECT
	cp.customer_id,
    c.customer_first_name,
    c.customer_last_name,
    SUM(cp.quantity * cp.cost_to_customer_per_qty) AS total_spent 
FROM farmers_market.customer AS c
	 LEFT JOIN farmers_market.customer_purchases AS cp
     ON c.customer_id = cp.customer_id
GROUP BY
	cp.customer_id,
    c.customer_first_name,
    c.customer_last_name
HAVING total_spent > 50
ORDER BY c.customer_last_name, c.customer_first_name;