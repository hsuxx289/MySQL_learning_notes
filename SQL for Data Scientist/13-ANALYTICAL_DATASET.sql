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
# 以顧客為基準 彙總購買資訊與郵遞區號
SELECT
	c.customer_id,
    c.customer_zip,
    DATEDIFF(MAX(market_date), MIN(market_date))
		AS customer_duration_days,
	COUNT(DISTINCT market_date) AS number_of_markets,
    ROUND(SUM(quantity * cost_to_customer_per_qty), 2)
		AS total_spent,
	ROUND(SUM(quantity * cost_to_customer_per_qty)
		/ COUNT(DISTINCT market_date), 2)
        AS average_spent_per_market
FROM farmers_market.customer AS c
	LEFT JOIN farmers_market.customer_purchases AS pc
		ON c.customer_id = pc.customer_id
GROUP BY c.customer_id;

# 將顧客購買資訊與人口統計資料結合
SELECT
	c.customer_id,
    DATEDIFF(MAX(market_date), MIN(market_date))
		AS customer_duration_days,
	COUNT(DISTINCT market_date) AS number_of_markets,
    ROUND(SUM(quantity * cost_to_customer_per_qty), 2)
		AS total_spent,
	ROUND(SUM(quantity * cost_to_customer_per_qty)
		/ COUNT(DISTINCT market_date), 2)
        AS average_spent_per_market,
	c.customer_zip,
    z.median_household_income AS zip_median_household_income,
    z.percent_high_income AS zip_percent_high_income,
    z.percent_under_18 AS zip_percent_under_18,
    z.percent_over_65 AS zip_percent_over_65,
    z.people_per_sq_mile AS zip_people_per_sq_mile,
    z.latitude,
    z.longitude
    
FROM farmers_market.customer AS c
	LEFT JOIN farmers_market.customer_purchases AS pc
		ON c.customer_id = pc.customer_id
	LEFT JOIN farmers_market.zip_data z
		ON c.customer_zip = z.zip_code_5
GROUP BY c.customer_id;

# 計算顧客居住地區與農夫市場的距離
SELECT
	c.customer_id,
    DATEDIFF(MAX(market_date), MIN(market_date))
		AS customer_duration_days,
	COUNT(DISTINCT market_date) AS number_of_markets,
    ROUND(SUM(quantity * cost_to_customer_per_qty), 2)
		AS total_spent,
	ROUND(SUM(quantity * cost_to_customer_per_qty)
		/ COUNT(DISTINCT market_date), 2)
        AS average_spent_per_market,
	c.customer_zip,
    z.median_household_income AS zip_median_household_income,
    z.percent_high_income AS zip_percent_high_income,
    z.percent_under_18 AS zip_percent_under_18,
    z.percent_over_65 AS zip_percent_over_65,
    z.people_per_sq_mile AS zip_people_per_sq_mile,
    
    ROUND(2 * 3961 * ASIN(SQRT(POWER(SIN(RADIANS(
		 (z.latitude - 38.4463) / 2)),2) +
         COS(RADIANS(38.4463)) * COS(RADIANS(z.latitude)) *
         POWER((SIN(RADIANS((z.longitude - -78.8712) / 2))), 2))))
         AS zip_miles_from_market
    
FROM farmers_market.customer AS c
	LEFT JOIN farmers_market.customer_purchases AS pc
		ON c.customer_id = pc.customer_id
	LEFT JOIN farmers_market.zip_data z
		ON c.customer_zip = z.zip_code_5
GROUP BY c.customer_id;

# 提供更多的分析想法
WITH customer_and_zip_data as
(
	SELECT
		c.customer_id,
		DATEDIFF(MAX(market_date), MIN(market_date))
			AS customer_duration_days,
		COUNT(DISTINCT market_date) AS number_of_markets,
		ROUND(SUM(quantity * cost_to_customer_per_qty), 2)
			AS total_spent,
		ROUND(SUM(quantity * cost_to_customer_per_qty)
			/ COUNT(DISTINCT market_date), 2)
			AS average_spent_per_market,
		c.customer_zip,
		z.median_household_income AS zip_median_household_income,
		z.percent_high_income AS zip_percent_high_income,
		z.percent_under_18 AS zip_percent_under_18,
		z.percent_over_65 AS zip_percent_over_65,
		z.people_per_sq_mile AS zip_people_per_sq_mile,
		
		ROUND(2 * 3961 * ASIN(SQRT(POWER(SIN(RADIANS(
			 (z.latitude - 38.4463) / 2)),2) +
			 COS(RADIANS(38.4463)) * COS(RADIANS(z.latitude)) *
			 POWER((SIN(RADIANS((z.longitude - -78.8712) / 2))), 2))))
			 AS zip_miles_from_market
		
	FROM farmers_market.customer AS c
		LEFT JOIN farmers_market.customer_purchases AS pc
			ON c.customer_id = pc.customer_id
		LEFT JOIN farmers_market.zip_data z
			ON c.customer_zip = z.zip_code_5
	GROUP BY c.customer_id
)

SELECT
	cz.customer_zip,
    COUNT(cz.customer_id) AS customer_count,
    ROUND(AVG(cz.total_spent)) AS average_total_spent,
    MIN(cz.zip_miles_from_market) AS zip_miles_from_market
FROM customer_and_zip_data AS cz
GROUP BY cz.customer_zip;

# 13.5 價格分布與高低價分析資料集
# 取產品價格的原始資料
SELECT
	p.product_id,
    p.product_name,
    p.product_category_id,
    p.product_qty_type,
    vi.vendor_id,
    vi.market_date,
    SUM(vi.quantity),
    AVG(vi.original_price)
FROM farmers_market.product AS p
	LEFT JOIN farmers_market.vendor_inventory AS vi
		ON p.product_id = vi.product_id
GROUP BY
	p.product_id,
    p.product_name,
    p.product_category_id,
    p.product_qty_type,
    vi.vendor_id,
    vi.market_date;
    
# 納入季節因素
SELECT
	p.product_id,
    p.product_name,
    p.product_category_id,
    p.product_qty_type,
    vi.vendor_id,
    MIN(MONTH(vi.market_date)) AS month_market_season_sort,
    md.market_year,
    md.market_season,
    SUM(vi.quantity),
    AVG(vi.original_price)
FROM farmers_market.product AS p
	LEFT JOIN farmers_market.vendor_inventory AS vi
		ON p.product_id = vi.product_id
	LEFT JOIN farmers_market.market_date_info AS md
		ON vi.market_date = md.market_date
GROUP BY
	p.product_id,
    p.product_name,
    p.product_category_id,
    p.product_qty_type,
    vi.vendor_id,
    md.market_year,
    md.market_season;
    
# 改用窗口函數
SELECT
	p.product_id,
    p.product_name,
    p.product_category_id,
    p.product_qty_type,
    vi.vendor_id,
    MIN(MONTH(vi.market_date)) OVER (PARTITION BY md.market_season) 
		AS month_market_season_sort,
    md.market_year,
    md.market_season,
    vi.original_price
FROM farmers_market.product AS p
	LEFT JOIN farmers_market.vendor_inventory AS vi
		ON p.product_id = vi.product_id
	LEFT JOIN farmers_market.market_date_info AS md
		ON vi.market_date = md.market_date;
        
# 納入實際銷售量與銷售額
SELECT
	sub.product_id,
    sub.product_name,
    sub.product_category_id,
    sub.product_qty_type,
    sub.vendor_id,
    sub.month_market_season_sort,
    sub.market_year,
    sub.market_season,
    AVG(sub.original_price) AS avg_original_price,
    SUM(sub.quantity) AS quantity_sold,
    SUM(sub.quantity * sub.cost_to_customer_per_qty)
		AS total_sales
FROM
(
	SELECT
		p.product_id,
		p.product_name,
		p.product_category_id,
		p.product_qty_type,
		vi.vendor_id,
		MIN(MONTH(vi.market_date)) OVER (PARTITION BY md.market_season) 
			AS month_market_season_sort,
		md.market_year,
		md.market_season,
		vi.original_price,
        cp.quantity,
        cp.cost_to_customer_per_qty
	FROM farmers_market.product AS p
		LEFT JOIN farmers_market.vendor_inventory AS vi
			ON p.product_id = vi.product_id
		LEFT JOIN farmers_market.market_date_info AS md
			ON vi.market_date = md.market_date
		LEFT JOIN farmers_market.customer_purchases AS cp
			ON vi.product_id = cp.product_id
				AND vi.vendor_id = cp.vendor_id
                AND vi.market_date = cp.market_date
) AS sub
GROUP BY
	sub.product_id,
    sub.product_name,
    sub.product_category_id,
    sub.product_qty_type,
    sub.vendor_id,
    sub.month_market_season_sort,
    sub.market_year,
    sub.market_season;

# 改用市集季節的角度將價格分級    
# 將每個季度內的價格分為低中高
SELECT
	sub.market_season,
    sub.market_year,
    sub.month_market_season_sort,
    sub.original_price,
	NTILE(3) OVER (PARTITION BY sub.market_year, sub.market_season
		ORDER BY sub.original_price) AS price_ntile,
	NTILE(3) OVER (PARTITION BY sub.market_year, sub.market_season
		ORDER BY sub.original_price DESC) AS price_ntile_desc,
	COUNT(DISTINCT CONCAT(sub.product_id, sub.vendor_id))
		AS product_count,
    SUM(sub.quantity) AS quantity_sold,
    SUM(sub.quantity * sub.cost_to_customer_per_qty)
		AS total_sales
FROM
(
	SELECT
		md.market_season,
        md.market_year,
		MIN(MONTH(vi.market_date)) OVER (PARTITION BY md.market_season) 
			AS month_market_season_sort,
		vi.product_id,
		vi.vendor_id,
		vi.original_price,
        cp.quantity,
        cp.cost_to_customer_per_qty
	FROM farmers_market.product AS p
		LEFT JOIN farmers_market.vendor_inventory AS vi
			ON p.product_id = vi.product_id
		LEFT JOIN farmers_market.market_date_info AS md
			ON vi.market_date = md.market_date
		LEFT JOIN farmers_market.customer_purchases AS cp
			ON vi.product_id = cp.product_id
				AND vi.vendor_id = cp.vendor_id
                AND vi.market_date = cp.market_date
	WHERE md.market_year IS NOT NULL
) AS sub
GROUP BY
	sub.market_year,
    sub.market_season,
    sub.month_market_season_sort,
    sub.original_price;
    
# 建立價格分析資料集
WITH sub AS
(
	SELECT
		md.market_season,
        md.market_year,
		MIN(MONTH(vi.market_date)) OVER (PARTITION BY md.market_season) 
			AS month_market_season_sort,
		vi.product_id,
		vi.vendor_id,
		vi.original_price,
        cp.quantity,
        cp.cost_to_customer_per_qty
	FROM farmers_market.product AS p
		LEFT JOIN farmers_market.vendor_inventory AS vi
			ON p.product_id = vi.product_id
		LEFT JOIN farmers_market.market_date_info AS md
			ON vi.market_date = md.market_date
		LEFT JOIN farmers_market.customer_purchases AS cp
			ON vi.product_id = cp.product_id
				AND vi.vendor_id = cp.vendor_id
                AND vi.market_date = cp.market_date
	WHERE md.market_year IS NOT NULL
),
hl AS
(
	SELECT
		sub.*,
		NTILE(3) OVER (PARTITION BY sub.market_year, sub.market_season
			ORDER BY sub.original_price) AS price_ntile,
		NTILE(3) OVER (PARTITION BY sub.market_year, sub.market_season
			ORDER BY sub.original_price DESC) AS price_ntile_desc
	FROM sub
)
SELECT
	hl.market_year,
    hl.market_season,
    hl.price_ntile,
    COUNT(DISTINCT CONCAT(hl.product_id, hl.vendor_id))
		AS product_count,
	SUM(hl.quantity) AS quantity_sold,
    MIN(hl.original_price) AS min_price,
    MAX(hl.original_price) AS max_price,
    SUM(hl.quantity * hl.cost_to_customer_per_qty)
		AS total_sales
	FROM hl
	GROUP BY
		hl.market_year,
        hl.market_season,
        hl.price_ntile,
        hl.month_market_season_sort
	ORDER BY
		hl.market_year,
        hl.month_market_season_sort;