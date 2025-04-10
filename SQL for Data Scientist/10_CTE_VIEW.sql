# 10.1
# 思考自訂資料集的需求
# 先找出需要用到的欄位
SELECT
	market_date,
    vendor_id,
    quantity * cost_to_customer_per_qty
FROM farmers_market.customer_purchases;

# 依照想要的方式分組
SELECT
	market_date,
    vendor_id,
    ROUND(SUM(quantity * cost_to_customer_per_qty), 2) AS sales
FROM farmers_market.customer_purchases
GROUP BY market_date, vendor_id
ORDER BY market_date, vendor_id;

# 加入其他有用的欄位資料
SELECT
	cp.market_date,
    md.market_day,
    md.market_week,
    md.market_year,
    cp.vendor_id,
    v.vendor_name,
    v.vendor_type,
    ROUND(SUM(cp.quantity * cp.cost_to_customer_per_qty), 2) AS sales
FROM farmers_market.customer_purchases AS cp
	LEFT JOIN farmers_market.market_date_info AS md
		ON cp.market_date = md.market_date
	LEFT JOIN farmers_market.vendor AS v
		ON cp.vendor_id = v.vendor_id
GROUP BY cp.market_date, cp.vendor_id
ORDER BY cp.market_date, cp.vendor_id;

# 10.2
# 可重複使用自訂資料集的方法: CTEs 和 Views
WITH sales_by_day_vendor AS
(
	SELECT
		cp.market_date,
		md.market_day,
		md.market_week,
		md.market_year,
		cp.vendor_id,
		v.vendor_name,
		v.vendor_type,
		ROUND(SUM(cp.quantity * cp.cost_to_customer_per_qty), 2) AS sales
	FROM farmers_market.customer_purchases AS cp
		LEFT JOIN farmers_market.market_date_info AS md
			ON cp.market_date = md.market_date
		LEFT JOIN farmers_market.vendor AS v
			ON cp.vendor_id = v.vendor_id
	GROUP BY cp.market_date, cp.vendor_id
	ORDER BY cp.market_date, cp.vendor_id
)

SELECT
	s.market_year,
    s.market_week,
    SUM(s.sales) AS weekly_sales
FROM sales_by_day_vendor AS s
GROUP BY s.market_year, s.market_week;

# 建立視圖
CREATE VIEW farmers_market.vw_sales_by_day_vendor AS
SELECT
	cp.market_date,
    md.market_day,
    md.market_week,
    md.market_year,
    cp.vendor_id,
    v.vendor_name,
    v.vendor_type,
    ROUND(SUM(cp.quantity * cp.cost_to_customer_per_qty), 2) AS sales
FROM farmers_market.customer_purchases AS cp
	LEFT JOIN farmers_market.market_date_info AS md
		ON cp.market_date = md.market_date
	LEFT JOIN farmers_market.vendor AS v
		ON cp.vendor_id = v.vendor_id
GROUP BY cp.market_date, cp.vendor_id
ORDER BY cp.market_date, cp.vendor_id;

# 查詢特定期間的供應商銷售狀況
SELECT *
FROM farmers_market.vw_sales_by_day_vendor AS s
WHERE s.market_date BETWEEN '2020-04-01' AND '2020-04-30'
	AND s.vendor_id = 7
ORDER BY market_date;

# 10.3
# SQL 為資料集增加更多可用性
# 將第9章範例作為視圖
CREATE VIEW farmers_market.vw_sales_per_date_vendor_product AS
SELECT
	vi.market_date,
    vi.vendor_id,
    v.vendor_name,
    vi.product_id,
    p.product_name,
    vi.quantity AS quantity_available,
    sales.quantity_sold,
    ROUND((sales.quantity_sold / vi.quantity) * 100, 2)
		AS percent_of_available_sold,
    vi.original_price,
    (vi.original_price * sales.quantity_sold) - sales.total_sales
		AS discount_amount,
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
		) AS sales
        ON vi.market_date = sales.market_date
			AND vi.vendor_id = sales.vendor_id
            AND vi.product_id = sales.product_id
	LEFT JOIN farmers_market.vendor AS v
		ON vi.vendor_id = v.vendor_id
	LEFT JOIN farmers_market.product AS p
		ON vi.product_id = p.product_id
ORDER BY vi.market_date, vi.vendor_id, vi.product_id;

# 供應商每個產品在各市集日期的銷售額占比
SELECT
	s.market_date,
    s.vendor_id,
    s.vendor_name,
    s.product_id,
    s.product_name,
    ROUND(s.total_sales, 2)
		AS vendor_product_sales_on_market_date,
	ROUND(SUM(s.total_sales) OVER (PARTITION BY market_date, vendor_id), 2)
		AS vendor_total_sales_on_market_date,
	ROUND((s.total_sales / SUM(s.total_sales) OVER (PARTITION BY market_date, vendor_id)) * 100, 1)
		AS product_percent_of_vendor_sales
from farmers_market.vw_sales_per_date_vendor_product AS s
ORDER BY market_date, vendor_id;

# 查詢特定的日期區間 供應商 與產品編號
SELECT
	market_date,
    vendor_name,
    product_name,
    quantity_available,
    quantity_sold
FROM farmers_market.vw_sales_per_date_vendor_product
WHERE market_date BETWEEN '2020-06-01' AND '2020-07-31'
	  AND vendor_name = "Marco's Peppers"
      AND product_id IN (2, 4)
ORDER BY market_date, product_id;

# practice
# 使用vw_sales_by_day_vendor 寫出一個可以輸出每個供應商每周銷售額的查詢 以供應商編號排序
SELECT
	market_week,
    market_year,
    vendor_id,
    vendor_name,
	SUM(sales) AS weekly_sales
FROM vw_sales_by_day_vendor
GROUP BY 
	market_week,
    market_year,
    vendor_id,
    vendor_name
ORDER BY vendor_id;

# 用 WITH 改寫 第七章 圖7.15 的查詢
WITH x AS
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
)
SELECT *
FROM x
WHERE x.market_date = '2019-04-10'
  AND ( x.booth_number <> x.previous_booth_number
  OR x.previous_booth_number is NULL);
  
# 如何將booth_number 與 booth_type 合併到10.1-3的查詢中
SELECT
	cp.market_date,
    md.market_day,
    md.market_week,
    md.market_year,
    cp.vendor_id,
    v.vendor_name,
    v.vendor_type,
    vba.booth_number,
    b.booth_type,
    ROUND(SUM(cp.quantity * cp.cost_to_customer_per_qty), 2) AS sales
FROM farmers_market.customer_purchases AS cp
	LEFT JOIN farmers_market.market_date_info AS md
		ON cp.market_date = md.market_date
	LEFT JOIN farmers_market.vendor AS v
		ON cp.vendor_id = v.vendor_id
	LEFT JOIN farmers_market.vendor_booth_assignments AS vba
		ON cp.vendor_id = vba.vendor_id
		   AND cp.market_date = vba.market_date
	LEFT JOIN farmers_market.booth AS b
		ON vba.booth_number = b.booth_number
GROUP BY 
	cp.market_date,
    md.market_day,
    md.market_week,
    md.market_year,
    cp.vendor_id,
    v.vendor_name,
    v.vendor_type,
    vba.booth_number,
    b.booth_type
ORDER BY cp.market_date, cp.vendor_id;