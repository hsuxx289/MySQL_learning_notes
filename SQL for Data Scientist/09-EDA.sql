# 9.2
# 探索product 表格
SELECT *
FROM farmers_market.product
LIMIT 5;

# 確認有無重複值
SELECT product_id, COUNT(*)
FROM farmers_market.product
GROUP BY product_id
HAVING COUNT(*) > 1;

# 查看 product_category 表格
SELECT *
FROM farmers_market.product_category;

# 查看有多少種產品
SELECT COUNT(*)
FROM farmers_market.product;

# 查看每個分類中有多少種產品
SELECT
	pc.product_category_id,
    pc.product_category_name,
    COUNT(p.product_id) AS count_of_products
FROM farmers_market.product_category AS pc
	LEFT JOIN farmers_market.product AS p
		on pc.product_category_id = p.product_category_id
GROUP BY pc.product_category_id;

# 探索product 表格中的計量單位有幾種
SELECT DISTINCT product_qty_type
FROM farmers_market.product;

# 探索 vendor_inventory 表格的欄位
SELECT * FROM farmers_market.vendor_inventory
LIMIT 10;

# 探索表格的欄位主鍵
SELECT market_date, vendor_id, product_id, COUNT(*)
FROM farmers_market.vendor_inventory
GROUP BY market_date, vendor_id, product_id
HAVING COUNT(*) > 1;

# 探索資料中的日期範圍
SELECT MIN(market_date), MAX(market_date)
FROM farmers_market.vendor_inventory;

# 探索供應商參與市集的日期範圍
SELECT vendor_id, MIN(market_date), MAX(market_date)
FROM farmers_market.vendor_inventory
GROUP BY vendor_id
ORDER BY vendor_id;

# 9.4
# 探索資料隨時間變化的情況
# 查看每個月有營業的供應商數量
SELECT
	EXTRACT(YEAR FROM market_date) AS market_year,
    EXTRACT(MONTH FROM market_date) AS market_month,
    COUNT(DISTINCT vendor_id) AS vendors_with_inventory
FROM farmers_market.vendor_inventory
GROUP BY EXTRACT(YEAR FROM market_date),
		 EXTRACT(MONTH FROM market_date)
ORDER BY EXTRACT(YEAR FROM market_date),
		 EXTRACT(MONTH FROM market_date);
         
# 查看特定供應商的存貨細節
SELECT * FROM farmers_market.vendor_inventory
WHERE vendor_id = 7
ORDER BY market_date, product_id;

# 9.5
# 探索多個表格(1) - 彙總銷售量
# 探索customer_purchases 表格的內容
SELECT * FROM farmers_market.customer_purchases
LIMIT 5;

# 觀察供應商7 供應產品4 的銷售狀況
SELECT * FROM farmers_market.customer_purchases
WHERE vendor_id = 7 AND product_id = 4
ORDER BY market_date, transaction_time;

# 探索某位顧客購買某樣產品的習性
SELECT * FROM farmers_market.customer_purchases
WHERE vendor_id = 7 AND product_id = 4 AND customer_id = 12
ORDER BY market_date, transaction_time;

# 彙總各市集日期某產品的銷量與營業額
SELECT 
	market_date,
    vendor_id,
    product_id,
    SUM(quantity) AS quantity_sold,
    ROUND(SUM(quantity * cost_to_customer_per_qty), 2)
		AS total_sales
FROM farmers_market.customer_purchases
WHERE vendor_id = 7 AND product_id = 4
GROUP BY market_date, vendor_id, product_id
ORDER BY market_date, vendor_id, product_id;

# 連結 vendor_inventory 與 customer_purchases 表格
SELECT *
FROM farmers_market.vendor_inventory AS vi
	LEFT JOIN
		(
         SELECT 
			market_date,
			vendor_id,
			product_id,
			SUM(quantity) AS quantity_sold,
			ROUND(SUM(quantity * cost_to_customer_per_qty), 2)
				AS total_sales
		 FROM farmers_market.customer_purchases
		 GROUP BY market_date, vendor_id, product_id
		 ORDER BY market_date, vendor_id, product_id
		) AS sales
        ON vi.market_date = sales.market_date
			AND vi.vendor_id = sales.vendor_id
            AND vi.product_id = sales.product_id
ORDER BY vi.market_date, vi.vendor_id, vi.product_id
LIMIT 10;

# 將供應商名稱與產品名稱納入
SELECT
	vi.market_date,
    vi.vendor_id, v.vendor_name,
    vi.product_id, p.product_name,
    vi.quantity AS quantity_available,
    sales.quantity_sold, vi.original_price,
    sales.total_sales
FROM farmers_market.vendor_inventory AS vi
	LEFT JOIN
		(
         SELECT 
			market_date,
			vendor_id,
			product_id,
			SUM(quantity) AS quantity_sold,
			ROUND(SUM(quantity * cost_to_customer_per_qty), 2)
				AS total_sales
		 FROM farmers_market.customer_purchases
		 GROUP BY market_date, vendor_id, product_id
		 ORDER BY market_date, vendor_id, product_id
		) AS sales
        ON vi.market_date = sales.market_date
			AND vi.vendor_id = sales.vendor_id
            AND vi.product_id = sales.product_id
	LEFT JOIN farmers_market.vendor AS v
		ON vi.vendor_id = v.vendor_id
	LEFT JOIN farmers_market.product AS p
		ON vi.product_id = p.product_id
WHERE vi.vendor_id = 7 AND vi.product_id = 4
ORDER BY vi.market_date, vi.vendor_id, vi.product_id;

# practice
# 查詢 customer_purchases 最早與最近的日期
SELECT MIN(market_date), MAX(market_date)
FROM farmers_market.customer_purchases;

# 計算Wednesday 和 Saturday 每小時有多少顧客
SELECT 
	DAYNAME(market_date),
    EXTRACT(HOUR FROM transaction_time),
    COUNT(DISTINCT customer_id)
FROM farmers_market.customer_purchases
GROUP BY DAYNAME(market_date), EXTRACT(HOUR FROM transaction_time)
ORDER BY DAYNAME(market_date), EXTRACT(HOUR FROM transaction_time);
