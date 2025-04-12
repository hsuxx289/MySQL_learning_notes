# 11.1
# 將兩個查詢結果聯集的UNION
# 用UNION 查詢2019 和2020 的第一天開市
SELECT market_year, MIN(market_date) AS first_market_date
FROM farmers_market.market_date_info
WHERE market_year = '2019'

UNION

SELECT market_year, MIN(market_date) AS first_market_date
FROM farmers_market.market_date_info
WHERE market_year = '2020';

# 用UNION ALL 直接合併
# 找出供應量最大的商品 區分單位
WITH product_quantity_by_date AS
(
	SELECT
		vi.market_date,
		vi.product_id,
		p.product_name,
		p.product_qty_type,
		SUM(vi.quantity) AS total_quantity_available
	FROM farmers_market.vendor_inventory AS vi
		LEFT JOIN farmers_market.product AS p
			on vi.product_id = p.product_id
	GROUP BY 
		vi.market_date,
		vi.product_id,
		p.product_name,
		p.product_qty_type
)

SELECT * FROM
(
	SELECT *,
		RANK() OVER (PARTITION BY market_date 
					 ORDER BY total_quantity_available DESC) AS quantity_rank
	FROM product_quantity_by_date
	WHERE product_qty_type = 'unit'

	UNION ALL

	SELECT *,
		RANK() OVER (PARTITION BY market_date 
					 ORDER BY total_quantity_available DESC) AS quantity_rank
	FROM product_quantity_by_date
	WHERE product_qty_type = 'lbs'
) AS x
WHERE x.quantity_rank = 1
ORDER BY market_date;

# 11.2
# 自我連結( Self-Join) 找出最大值
# 將某一市集日期銷售額與之前銷售額並列
# 先匯總每日銷售額 CTE
WITH
sales_per_market_date AS
(
	SELECT
		market_date,
		ROUND(SUM(quantity * cost_to_customer_per_qty), 2) AS sales
	FROM farmers_market.customer_purchases
	GROUP BY market_date
	ORDER BY market_date
)

SELECT *
FROM sales_per_market_date
LIMIT 10;

# 尋找比2019-04-13早的市集日期
WITH
sales_per_market_date AS
(
	SELECT
		market_date,
		ROUND(SUM(quantity * cost_to_customer_per_qty), 2) AS sales
	FROM farmers_market.customer_purchases
	GROUP BY market_date
	ORDER BY market_date
)

SELECT *
FROM sales_per_market_date AS cm
 LEFT JOIN sales_per_market_date AS pm
	ON pm.market_date < cm.market_date
WHERE cm.market_date = '2019-04-13';

# 將上面的查詢結果GROUP BY market_date 與 sales
# 即可取pm.market_date 的 MAX 對照
WITH
sales_per_market_date AS
(
	SELECT
		market_date,
		ROUND(SUM(quantity * cost_to_customer_per_qty), 2) AS sales
	FROM farmers_market.customer_purchases
	GROUP BY market_date
	ORDER BY market_date
)

SELECT
	cm.market_date,
    cm.sales,
    MAX(pm.sales) AS previous_max_sales
FROM sales_per_market_date AS cm
 LEFT JOIN sales_per_market_date AS pm
	ON pm.market_date < cm.market_date
WHERE cm.market_date = '2019-04-13'
GROUP BY cm.market_date, cm.sales;

# 設定是否為創歷史新高的指標
# 加上CASE 即可
WITH
sales_per_market_date AS
(
	SELECT
		market_date,
		ROUND(SUM(quantity * cost_to_customer_per_qty), 2) AS sales
	FROM farmers_market.customer_purchases
	GROUP BY market_date
	ORDER BY market_date
)
SELECT * FROM
(
	SELECT
		cm.market_date,
		cm.sales,
		MAX(pm.sales) AS previous_max_sales,
		CASE WHEN cm.sales > MAX(pm.sales)
			THEN "YES" ELSE "NO"
		END AS sales_record_set
	FROM sales_per_market_date AS cm
	 LEFT JOIN sales_per_market_date AS pm
		ON pm.market_date < cm.market_date
	GROUP BY cm.market_date, cm.sales
) AS x
WHERE x.sales_record_set = "YES";

# 11.3
# 統計每周的新顧客與回頭客
# 將顧客每次購買日期與首次購買日期並列
SELECT DISTINCT
	customer_id,
    market_date,
    MIN(market_date) OVER (PARTITION BY customer_id)
		AS first_purchase_date
FROM farmers_market.customer_purchases;

# 計算每周的顧客數跟不重複顧客數
WITH
customer_markets_attended AS
(
	SELECT DISTINCT
		customer_id,
		market_date,
		MIN(market_date) OVER (PARTITION BY customer_id)
			AS first_purchase_date
	FROM farmers_market.customer_purchases
)

SELECT
	md.market_year, md.market_week,
    COUNT(customer_id) AS customer_visit_count,
    COUNT(DISTINCT customer_id) AS distinct_customer_count
FROM customer_markets_attended AS cma
	LEFT JOIN farmers_market.market_date_info AS md
		on cma.market_date = md.market_date
GROUP BY md.market_year, md.market_week
ORDER BY md.market_year, md.market_week;

# 找出新顧客的人數與佔比
WITH
customer_markets_attended AS
(
	SELECT DISTINCT
		customer_id,
		market_date,
		MIN(market_date) OVER (PARTITION BY customer_id)
			AS first_purchase_date
	FROM farmers_market.customer_purchases
)

SELECT
	md.market_year, md.market_week,
    COUNT(customer_id) AS customer_visit_count,
    COUNT(DISTINCT customer_id) AS distinct_customer_count,
    
    COUNT(
		DISTINCT
        CASE WHEN cma.market_date = cma.first_purchase_date
			THEN customer_id
            ELSE NULL
		END
        ) AS new_customer_count,
        
	COUNT(
		DISTINCT
        CASE WHEN cma.market_date = cma.first_purchase_date
			THEN customer_id
            ELSE NULL
		END
        ) / COUNT(DISTINCT customer_id)
        AS new_customer_percent
        
FROM customer_markets_attended AS cma
	LEFT JOIN farmers_market.market_date_info AS md
		on cma.market_date = md.market_date
GROUP BY md.market_year, md.market_week
ORDER BY md.market_year, md.market_week;

# practice
# 改寫11.2 把原本主查詢的敘述放在with 的第二個位置
# 將創下紀錄的日期與銷售額列出 依日期降冪排列
WITH
sales_per_market_date AS
(
	SELECT
		market_date,
		ROUND(SUM(quantity * cost_to_customer_per_qty), 2) AS sales
	FROM farmers_market.customer_purchases
	GROUP BY market_date
	ORDER BY market_date
),

record_sales_per_market_date AS
(
	SELECT
		cm.market_date,
		cm.sales,
		MAX(pm.sales) AS previous_max_sales,
		CASE WHEN cm.sales > MAX(pm.sales)
			THEN "YES" ELSE "NO"
		END AS sales_record_set
	FROM sales_per_market_date AS cm
	 LEFT JOIN sales_per_market_date AS pm
		ON pm.market_date < cm.market_date
	GROUP BY cm.market_date, cm.sales
)
SELECT market_date, sales
FROM record_sales_per_market_date
WHERE sales_record_set = "YES"
ORDER BY market_date DESC;

# 找出每年每周每供應商的新顧客跟回頭客各有多少
WITH
customer_markets_attended AS
(
	SELECT DISTINCT
		customer_id,
        vendor_id,
		market_date,
		MIN(market_date) OVER (PARTITION BY customer_id, vendor_id)
			AS first_purchase_from_vendor_date
	FROM farmers_market.customer_purchases
)

SELECT md.market_year, md.market_week,
	cma.vendor_id,
    COUNT(customer_id) AS customer_visit_count,
    COUNT(DISTINCT customer_id) AS distinct_customer_count,
    
    COUNT(
		DISTINCT
        CASE WHEN cma.market_date = cma.first_purchase_from_vendor_date
			THEN customer_id
            ELSE NULL
		END
        ) AS new_customer_count,
        
	COUNT(
		DISTINCT
        CASE WHEN cma.market_date = cma.first_purchase_from_vendor_date
			THEN customer_id
            ELSE NULL
		END
        ) / COUNT(DISTINCT customer_id)
        AS new_customer_percent
        
FROM customer_markets_attended AS cma
	LEFT JOIN farmers_market.market_date_info AS md
		on cma.market_date = md.market_date
GROUP BY md.market_year, md.market_week, cma.vendor_id
ORDER BY md.market_year, md.market_week, cma.vendor_id;

# 聯集銷售額最高與最低的日期銷售額與銷售排名
WITH
sales_per_market_date AS
(
	SELECT
		market_date,
		ROUND(SUM(quantity * cost_to_customer_per_qty), 2) AS sales,
        RANK() OVER (ORDER BY ROUND(SUM(quantity * cost_to_customer_per_qty), 2)) AS sales_rank_asc,
        RANK() OVER (ORDER BY ROUND(SUM(quantity * cost_to_customer_per_qty), 2) DESC) AS sales_rank_desc
	FROM farmers_market.customer_purchases
	GROUP BY market_date
),

market_dates_ranked_by_sales AS
(
	SELECT
		market_date,
		sales,
        RANK() OVER (ORDER BY sales) AS sales_rank_asc,
        RANK() OVER (ORDER BY sales DESC) AS sales_rank_desc
	FROM sales_per_market_date
)

SELECT market_date, sales, sales_rank_desc AS sales_rank
FROM market_dates_ranked_by_sales
WHERE sales_rank_asc = 1

UNION

SELECT market_date, sales, sales_rank_desc AS sales_rank
FROM market_dates_ranked_by_sales
WHERE sales_rank_desc = 1;