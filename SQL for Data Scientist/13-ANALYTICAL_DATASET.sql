# 13.1
# 生鮮蔬果銷售分析資料集(1): 影響銷售額的氣象、季節因素
# 查看那些種類可能包含生鮮蔬果
SELECT * FROM farmers_market.product_category;

# 確認種類內含品項
SELECT * 
FROM farmers_market.product
WHERE product_category_id IN (1, 5, 6)
ORDER BY product_category_id;

# 查看表單所有欄位
SELECT *
FROM farmers_market.customer_purchases AS cp
	INNER JOIN farmers_market.product AS p
		ON cp.product_id = p.product_id
WHERE p.product_category_id = 1;

# 挑選需要輸出的欄位
SELECT
	cp.market_date,
    cp.customer_id,
    cp.quantity,
    cp.cost_to_customer_per_qty,
    p.product_category_id,
    md.market_date,
    md.market_week,
    md.market_year,
    md.market_rain_flag,
    md.market_snow_flag
FROM farmers_market.customer_purchases AS cp
	INNER JOIN farmers_market.product AS p
		ON cp.product_id = p.product_id
	RIGHT JOIN farmers_market.market_date_info AS md
		ON cp.market_date = md.market_date
WHERE p.product_category_id = 1;

# 修改查詢條件
SELECT
	cp.market_date,
    cp.customer_id,
    cp.quantity,
    cp.cost_to_customer_per_qty,
    p.product_category_id,
    md.market_date,
    md.market_week,
    md.market_year,
    md.market_rain_flag,
    md.market_snow_flag
FROM farmers_market.customer_purchases AS cp
	INNER JOIN farmers_market.product AS p
		ON cp.product_id = p.product_id
			AND p.product_category_id = 1
	RIGHT JOIN farmers_market.market_date_info AS md
		ON md.market_date = cp.market_date;
        
# 彙總每周銷售額與氣象資料 - 用COALESCE 處理NULL
SELECT
	md.market_year,
    md.market_week,
    MAX(md.market_rain_flag) AS market_week_rain_flag,
    MAX(md.market_snow_flag) AS market_week_snow_flag,
    MIN(md.market_min_temp) AS minimum_temperature,
    MAX(md.market_max_temp) AS maximum_temperature,
    MIN(md.market_season) AS market_season,
    ROUND(SUM(coalesce(cp.quantity * cp.cost_to_customer_per_qty, 0)),2)
		AS weekly_category1_sales
FROM farmers_market.customer_purchases AS cp
	INNER JOIN farmers_market.product AS p
		ON cp.product_id = p.product_id
			AND p.product_category_id = 1
	RIGHT JOIN farmers_market.market_date_info AS md
		ON md.market_date = cp.market_date
GROUP BY md.market_year, md.market_week;

# 13.2
# 生鮮蔬果銷售分析資料集(2): 供應商產品與存貨因素
# 查看供應商在每次市集的資料
SELECT
	md.market_date,
    md.market_year,
    md.market_week,
    vi.*,
    p.*
FROM farmers_market.vendor_inventory AS vi
	INNER JOIN farmers_market.product AS p
		ON vi.product_id = p.product_id
			AND p.product_category_id = 1
	RIGHT JOIN market_date_info AS md
		ON md.market_date = vi.market_date;
        
# 挑選需要的欄位 並關注特定產品
SELECT
    md.market_year,
    md.market_week,
	COUNT(DISTINCT vi.vendor_id) AS vendor_count,
    COUNT(DISTINCT vi.product_id) AS unique_product_count,
    SUM(CASE WHEN p.product_qty_type = 'unit' THEN vi.quantity
			ELSE 0 END) AS unit_product_qty,
    SUM(CASE WHEN p.product_qty_type = 'lbs' THEN vi.quantity
			ELSE 0 END) AS unit_product_lbs,
	ROUND(SUM(COALESCE(vi.quantity * vi.original_price,0)), 2)
		AS total_product_value,
	MAX(CASE WHEN p.product_id = 16 THEN 1 ELSE 0 END)
		AS corn_availale_flag
    
FROM farmers_market.vendor_inventory AS vi
	INNER JOIN farmers_market.product AS p
		ON vi.product_id = p.product_id
			AND p.product_category_id = 1
	RIGHT JOIN market_date_info AS md
		ON md.market_date = vi.market_date
GROUP BY md.market_year, md.market_week;

# 考慮更廣泛的適用性 將生鮮蔬果種類獨立出來
SELECT
    md.market_year,
    md.market_week,
    
	COUNT(DISTINCT vi.vendor_id) AS vendor_count,
    
    COUNT(DISTINCT
		CASE WHEN p.product_category_id = 1
			THEN vi.vendor_id ELSE NULL END
	) AS vendor_count_product_category1,
    
    COUNT(DISTINCT vi.product_id) AS unique_product_count,

    COUNT(DISTINCT
		CASE WHEN p.product_category_id = 1
			THEN vi.product_id ELSE NULL END
	) AS unique_product_count_product_category1,

    SUM(CASE WHEN p.product_qty_type = 'unit' THEN vi.quantity
			ELSE 0 END) AS unit_product_qty,
            
	SUM(CASE WHEN p.product_category_id = 1
				AND p.product_qty_type = 'unit'
			 THEN vi.quantity ELSE 0 END
	) AS unit_product_qty_product_category1,
            
    SUM(CASE WHEN p.product_qty_type = 'lbs' THEN vi.quantity
			ELSE 0 END) AS unit_product_lbs,

	SUM(CASE WHEN p.product_category_id = 1
				AND p.product_qty_type = 'lbs'
			 THEN vi.quantity ELSE 0 END
	) AS lbs_product_qty_product_category1,

	ROUND(SUM(COALESCE(vi.quantity * vi.original_price,0)), 2)
		AS total_product_value,

	ROUND(SUM(COALESCE(CASE WHEN p.product_category_id = 1
		THEN vi.quantity * vi.original_price ELSE 0 END, 0)), 2)
		AS total_product_value_product_category1,

	MAX(CASE WHEN p.product_id = 16 THEN 1 ELSE 0 END)
		AS corn_availale_flag
    
FROM farmers_market.vendor_inventory AS vi
	INNER JOIN farmers_market.product AS p
		ON vi.product_id = p.product_id
	RIGHT JOIN market_date_info AS md
		ON md.market_date = vi.market_date
GROUP BY md.market_year, md.market_week;

# 13.3
# 生鮮蔬果銷售分析資料集(3): 整合市集與供應商的影響因素
# 將13.1 / 13.2的查詢 放進CTE 輸出全部欄位
WITH
my_customer_purchases AS
(
	SELECT
		md.market_year,
		md.market_week,
		MAX(md.market_rain_flag) AS market_week_rain_flag,
		MAX(md.market_snow_flag) AS market_week_snow_flag,
		MIN(md.market_min_temp) AS minimum_temperature,
		MAX(md.market_max_temp) AS maximum_temperature,
		MIN(md.market_season) AS market_season,
		ROUND(SUM(coalesce(cp.quantity * cp.cost_to_customer_per_qty, 0)),2)
			AS weekly_category1_sales
	FROM farmers_market.customer_purchases AS cp
		INNER JOIN farmers_market.product AS p
			ON cp.product_id = p.product_id
				AND p.product_category_id = 1
		RIGHT JOIN farmers_market.market_date_info AS md
			ON md.market_date = cp.market_date
	GROUP BY md.market_year, md.market_week
),
my_vendor_inventory AS
(
	SELECT
		md.market_year,
		md.market_week,
		
		COUNT(DISTINCT vi.vendor_id) AS vendor_count,
		
		COUNT(DISTINCT
			CASE WHEN p.product_category_id = 1
				THEN vi.vendor_id ELSE NULL END
		) AS vendor_count_product_category1,
		
		COUNT(DISTINCT vi.product_id) AS unique_product_count,

		COUNT(DISTINCT
			CASE WHEN p.product_category_id = 1
				THEN vi.product_id ELSE NULL END
		) AS unique_product_count_product_category1,

		SUM(CASE WHEN p.product_qty_type = 'unit' THEN vi.quantity
				ELSE 0 END) AS unit_product_qty,
				
		SUM(CASE WHEN p.product_category_id = 1
					AND p.product_qty_type = 'unit'
				 THEN vi.quantity ELSE 0 END
		) AS unit_product_qty_product_category1,
				
		SUM(CASE WHEN p.product_qty_type = 'lbs' THEN vi.quantity
				ELSE 0 END) AS unit_product_lbs,

		SUM(CASE WHEN p.product_category_id = 1
					AND p.product_qty_type = 'lbs'
				 THEN vi.quantity ELSE 0 END
		) AS lbs_product_qty_product_category1,

		ROUND(SUM(COALESCE(vi.quantity * vi.original_price,0)), 2)
			AS total_product_value,

		ROUND(SUM(COALESCE(CASE WHEN p.product_category_id = 1
			THEN vi.quantity * vi.original_price ELSE 0 END, 0)), 2)
			AS total_product_value_product_category1,

		MAX(CASE WHEN p.product_id = 16 THEN 1 ELSE 0 END)
			AS corn_availale_flag
		
	FROM farmers_market.vendor_inventory AS vi
		INNER JOIN farmers_market.product AS p
			ON vi.product_id = p.product_id
		RIGHT JOIN market_date_info AS md
			ON md.market_date = vi.market_date
	GROUP BY md.market_year, md.market_week
)

SELECT *
FROM my_vendor_inventory
	LEFT JOIN my_customer_purchases
		ON my_vendor_inventory.market_year = my_customer_purchases.market_year
			AND my_vendor_inventory.market_week = my_customer_purchases.market_week
ORDER BY my_vendor_inventory.market_year, my_vendor_inventory.market_week;

# 利用窗口函數將前一周銷售額也放進資料集
WITH
my_customer_purchases AS
(
	SELECT
		md.market_year,
		md.market_week,
		MAX(md.market_rain_flag) AS market_week_rain_flag,
		MAX(md.market_snow_flag) AS market_week_snow_flag,
		MIN(md.market_min_temp) AS minimum_temperature,
		MAX(md.market_max_temp) AS maximum_temperature,
		MIN(md.market_season) AS market_season,
		ROUND(SUM(coalesce(cp.quantity * cp.cost_to_customer_per_qty, 0)),2)
			AS weekly_category1_sales
	FROM farmers_market.customer_purchases AS cp
		INNER JOIN farmers_market.product AS p
			ON cp.product_id = p.product_id
				AND p.product_category_id = 1
		RIGHT JOIN farmers_market.market_date_info AS md
			ON md.market_date = cp.market_date
	GROUP BY md.market_year, md.market_week
),
my_vendor_inventory AS
(
	SELECT
		md.market_year,
		md.market_week,
		
		COUNT(DISTINCT vi.vendor_id) AS vendor_count,
		
		COUNT(DISTINCT
			CASE WHEN p.product_category_id = 1
				THEN vi.vendor_id ELSE NULL END
		) AS vendor_count_product_category1,
		
		COUNT(DISTINCT vi.product_id) AS unique_product_count,

		COUNT(DISTINCT
			CASE WHEN p.product_category_id = 1
				THEN vi.product_id ELSE NULL END
		) AS unique_product_count_product_category1,

		SUM(CASE WHEN p.product_qty_type = 'unit' THEN vi.quantity
				ELSE 0 END) AS unit_product_qty,
				
		SUM(CASE WHEN p.product_category_id = 1
					AND p.product_qty_type = 'unit'
				 THEN vi.quantity ELSE 0 END
		) AS unit_product_qty_product_category1,
				
		SUM(CASE WHEN p.product_qty_type = 'lbs' THEN vi.quantity
				ELSE 0 END) AS unit_product_lbs,

		SUM(CASE WHEN p.product_category_id = 1
					AND p.product_qty_type = 'lbs'
				 THEN vi.quantity ELSE 0 END
		) AS lbs_product_qty_product_category1,

		ROUND(SUM(COALESCE(vi.quantity * vi.original_price,0)), 2)
			AS total_product_value,

		ROUND(SUM(COALESCE(CASE WHEN p.product_category_id = 1
			THEN vi.quantity * vi.original_price ELSE 0 END, 0)), 2)
			AS total_product_value_product_category1,

		MAX(CASE WHEN p.product_id = 16 THEN 1 ELSE 0 END)
			AS corn_availale_flag
		
	FROM farmers_market.vendor_inventory AS vi
		INNER JOIN farmers_market.product AS p
			ON vi.product_id = p.product_id
		RIGHT JOIN market_date_info AS md
			ON md.market_date = vi.market_date
	GROUP BY md.market_year, md.market_week
)

SELECT
	mvi.market_year,
    mvi.market_week,
    mcp.market_week_rain_flag,
    mcp.market_week_snow_flag,
    mcp.minimum_temperature,
    mcp.maximum_temperature,
    mcp.market_season,
    mvi.vendor_count,
    mvi.vendor_count_product_category1,
    mvi.unique_product_count,
    mvi.unique_product_count_product_category1,
    mvi.unit_product_qty, 
    mvi.unit_product_qty_product_category1,
    mvi.unit_product_lbs,
    mvi.lbs_product_qty_product_category1,
    mvi.total_product_value,
    mvi.total_product_value_product_category1,
    LAG(mcp.weekly_category1_sales, 1) OVER (ORDER BY mvi.market_year,
		mvi.market_week) AS previous_week_category1_sales,
    mcp.weekly_category1_sales
FROM my_vendor_inventory AS mvi
	LEFT JOIN my_customer_purchases AS mcp
		ON mvi.market_year = mcp.market_year
			AND mvi.market_week = mcp.market_week
ORDER BY mvi.market_year, mvi.market_week;

# 13.4
# 顧客居住地區與人口統計分析資料集
