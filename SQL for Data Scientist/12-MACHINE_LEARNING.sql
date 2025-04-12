# 12.1
# 時間序列模型的資料集
# 先使用銷售額單一變數 來建立以周作為時間段的資料集
SELECT
	MIN(cp.market_date) AS first_market_date_of_week,
    ROUND(SUM(cp.quantity * cp.cost_to_customer_per_qty), 2)
		AS weekly_sales
FROM farmers_market.customer_purchases AS cp
	LEFT JOIN farmers_market.market_date_info AS md
		ON cp.market_date = md.market_date
GROUP BY md.market_year, md.market_week
ORDER BY md.market_year, md.market_week;

# 12.2
# 二元分類模型的資料集
# 每位顧客不重複的購買日期CTE
WITH
customer_markets_attended AS
(
	SELECT DISTINCT
		customer_id,
        market_date
	FROM farmers_market.customer_purchases
    ORDER BY customer_id, market_date
);

# 建立資料集的查詢
WITH
customer_markets_attended AS
(
	SELECT DISTINCT
		customer_id,
        market_date
	FROM farmers_market.customer_purchases
    ORDER BY customer_id, market_date
)

SELECT
	cp.market_date,
    cp.customer_id,
    SUM(cp.quantity * cp.cost_to_customer_per_qty)
		AS purchase_total,
        
	COUNT(DISTINCT cp.vendor_id) AS vendor_patronized,
    COUNT(DISTINCT cp.product_id) AS different_products_purchased,
    
    ( SELECT MIN(cma.market_date)
	  FROM customer_markets_attended AS cma
      WHERE cma.customer_id = cp.customer_id
		AND cma.market_date > cp.market_date
	  GROUP BY cma.customer_id
	) AS customer_next_market_date,
    
    DATEDIFF(
		( SELECT MIN(cma2.market_date)
		  FROM customer_markets_attended AS cma2
		  WHERE cma2.customer_id = cp.customer_id
			AND cma2.market_date > cp.market_date
		  GROUP BY cma2.customer_id
		), cp.market_date) 
	AS days_until_customer_next_market_date,

	CASE WHEN
        DATEDIFF(
		( SELECT MIN(cma3.market_date)
		  FROM customer_markets_attended AS cma3
		  WHERE cma3.customer_id = cp.customer_id
			AND cma3.market_date > cp.market_date
		  GROUP BY cma3.customer_id
		), cp.market_date) <=30
        THEN 1 ELSE 0
	END AS purchased_again_within_30_days
		
FROM farmers_market.customer_purchases AS cp
GROUP BY cp.customer_id, cp.market_date
ORDER BY cp.customer_id, cp.market_date;

# 擴增特徵欄位 - 供應商是否有交易 上次交易距今天數
WITH
customer_markets_attended AS
(
	SELECT DISTINCT
		customer_id,
        market_date
	FROM farmers_market.customer_purchases
    ORDER BY customer_id, market_date
)

SELECT
	cp.market_date,
    cp.customer_id,
    SUM(cp.quantity * cp.cost_to_customer_per_qty)
		AS purchase_total,
        
	COUNT(DISTINCT cp.vendor_id) AS vendor_patronized,
    
    MAX(CASE WHEN cp.vendor_id = 7 THEN 1 ELSE 0 END)
		AS purchased_from_vendor_7,
        
	MAX(CASE WHEN cp.vendor_id = 8 THEN 1 ELSE 0 END)
		AS purchased_from_vendor_8,
    
    COUNT(DISTINCT cp.product_id) AS different_products_purchased,

	DATEDIFF(cp.market_date,
		( SELECT MAX(cma.market_date)
		  FROM customer_markets_attended AS cma
		  WHERE cma.customer_id = cp.customer_id
			AND cma.market_date < cp.market_date
		  GROUP BY cma.customer_id)
		) AS days_since_last_customer_market_date,

	CASE WHEN
        DATEDIFF(
		( SELECT MIN(cma.market_date)
		  FROM customer_markets_attended AS cma
		  WHERE cma.customer_id = cp.customer_id
			AND cma.market_date > cp.market_date
		  GROUP BY cma.customer_id
		), cp.market_date) <=30
        THEN 1 ELSE 0
	END AS purchased_again_within_30_days
		
FROM farmers_market.customer_purchases AS cp
GROUP BY cp.customer_id, cp.market_date
ORDER BY cp.customer_id, cp.market_date;

# 擴增特徵欄位 - 顧客來過市集的次數
WITH
customer_markets_attended AS
(
	SELECT
		customer_id,
        market_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id
			ORDER BY market_date) AS market_count
	FROM farmers_market.customer_purchases
    GROUP BY customer_id, market_date
    ORDER BY customer_id, market_date
)

SELECT
	cp.market_date,
    cp.customer_id,
    SUM(cp.quantity * cp.cost_to_customer_per_qty)
		AS purchase_total,
        
	COUNT(DISTINCT cp.vendor_id) AS vendor_patronized,
    
    MAX(CASE WHEN cp.vendor_id = 7 THEN 1 ELSE 0 END)
		AS purchased_from_vendor_7,
        
	MAX(CASE WHEN cp.vendor_id = 8 THEN 1 ELSE 0 END)
		AS purchased_from_vendor_8,
    
    COUNT(DISTINCT cp.product_id) AS different_products_purchased,

	DATEDIFF(cp.market_date,
		( SELECT MAX(cma.market_date)
		  FROM customer_markets_attended AS cma
		  WHERE cma.customer_id = cp.customer_id
			AND cma.market_date < cp.market_date
		  GROUP BY cma.customer_id)
		) AS days_since_last_customer_market_date,
        
	( SELECT MAX(market_count)
	  FROM customer_markets_attended AS cma
      WHERE cma.customer_id = cp.customer_id
		AND cma.market_date <= cp.market_date
	) AS customer_markets_attended_count,
    
	CASE WHEN
        DATEDIFF(
		( SELECT MIN(cma.market_date)
		  FROM customer_markets_attended AS cma
		  WHERE cma.customer_id = cp.customer_id
			AND cma.market_date > cp.market_date
		  GROUP BY cma.customer_id
		), cp.market_date) <=30
        THEN 1 ELSE 0
	END AS purchased_again_within_30_days
		
FROM farmers_market.customer_purchases AS cp
GROUP BY cp.customer_id, cp.market_date
ORDER BY cp.customer_id, cp.market_date;


# 擴增特徵欄位 - 顧客在過去30天內來市集的次數
WITH
customer_markets_attended AS
(
	SELECT
		customer_id,
        market_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id
			ORDER BY market_date) AS market_count
	FROM farmers_market.customer_purchases
    GROUP BY customer_id, market_date
    ORDER BY customer_id, market_date
)

SELECT
	cp.market_date,
    cp.customer_id,
    SUM(cp.quantity * cp.cost_to_customer_per_qty)
		AS purchase_total,
        
	COUNT(DISTINCT cp.vendor_id) AS vendor_patronized,
    
    MAX(CASE WHEN cp.vendor_id = 7 THEN 1 ELSE 0 END)
		AS purchased_from_vendor_7,
        
	MAX(CASE WHEN cp.vendor_id = 8 THEN 1 ELSE 0 END)
		AS purchased_from_vendor_8,
    
    COUNT(DISTINCT cp.product_id) AS different_products_purchased,

	DATEDIFF(cp.market_date,
		( SELECT MAX(cma.market_date)
		  FROM customer_markets_attended AS cma
		  WHERE cma.customer_id = cp.customer_id
			AND cma.market_date < cp.market_date
		  GROUP BY cma.customer_id)
		) AS days_since_last_customer_market_date,
        
	( SELECT MAX(market_count)
	  FROM customer_markets_attended AS cma
      WHERE cma.customer_id = cp.customer_id
		AND cma.market_date <= cp.market_date
	) AS customer_markets_attended_count,
    
    ( SELECT COUNT(market_date)
      FROM customer_markets_attended AS cma
      WHERE cma.customer_id = cp.customer_id
		AND cma.market_date < cp.market_date
        AND DATEDIFF(cp.market_date, cma.market_date) <= 30
	) AS customer_markets_attended_30days_count,
    
	CASE WHEN
        DATEDIFF(
		( SELECT MIN(cma.market_date)
		  FROM customer_markets_attended AS cma
		  WHERE cma.customer_id = cp.customer_id
			AND cma.market_date > cp.market_date
		  GROUP BY cma.customer_id
		), cp.market_date) <=30
        THEN 1 ELSE 0
	END AS purchased_again_within_30_days
		
FROM farmers_market.customer_purchases AS cp
GROUP BY cp.customer_id, cp.market_date
ORDER BY cp.customer_id, cp.market_date;

# practice
# 使用上面的查詢
# 新增14天內消費的欄位
# 新增消費超過$10的欄位
# 新增累積消費超過$200的欄位
WITH
customer_markets_attended AS
(
	SELECT
		customer_id,
        market_date,
        SUM(quantity * cost_to_customer_per_qty) AS purchase_total,
        ROW_NUMBER() OVER (PARTITION BY customer_id
			ORDER BY market_date) AS market_count
	FROM farmers_market.customer_purchases
    GROUP BY customer_id, market_date
    ORDER BY customer_id, market_date
)

SELECT
	cp.market_date,
    cp.customer_id,
    SUM(cp.quantity * cp.cost_to_customer_per_qty)
		AS purchase_total,
        
	COUNT(DISTINCT cp.vendor_id) AS vendor_patronized,
    
    MAX(CASE WHEN cp.vendor_id = 7 THEN 1 ELSE 0 END)
		AS purchased_from_vendor_7,
        
	MAX(CASE WHEN cp.vendor_id = 8 THEN 1 ELSE 0 END)
		AS purchased_from_vendor_8,
    
    COUNT(DISTINCT cp.product_id) AS different_products_purchased,

	DATEDIFF(cp.market_date,
		( SELECT MAX(cma.market_date)
		  FROM customer_markets_attended AS cma
		  WHERE cma.customer_id = cp.customer_id
			AND cma.market_date < cp.market_date
		  GROUP BY cma.customer_id)
		) AS days_since_last_customer_market_date,
        
	( SELECT MAX(market_count)
	  FROM customer_markets_attended AS cma
      WHERE cma.customer_id = cp.customer_id
		AND cma.market_date <= cp.market_date
	) AS customer_markets_attended_count,
    
    ( SELECT COUNT(market_date)
      FROM customer_markets_attended AS cma
      WHERE cma.customer_id = cp.customer_id
		AND cma.market_date < cp.market_date
        AND DATEDIFF(cp.market_date, cma.market_date) <= 14
	) AS customer_markets_attended_14days_count,
    
    MAX(CASE WHEN cp.cost_to_customer_per_qty > 10 THEN 1 ELSE 0 END)
		AS purchased_item_over_10_dollars,
    
    ( SELECT SUM(purchase_total)
      FROM customer_markets_attended AS cma
      WHERE cma.customer_id = cp.customer_id
		AND cma.market_date <= cp.market_date
	) AS total_spent_to_date,
    
    CASE WHEN
		( SELECT SUM(purchase_total)
		  FROM customer_markets_attended AS cma
		  WHERE cma.customer_id = cp.customer_id
			AND cma.market_date <= cp.market_date) > 200
		 THEN 1 ELSE 0
	END AS customer_has_spent_over_200,
	
    
    ( SELECT COUNT(market_date)
      FROM customer_markets_attended AS cma
      WHERE cma.customer_id = cp.customer_id
		AND cma.market_date < cp.market_date
        AND DATEDIFF(cp.market_date, cma.market_date) <= 30
	) AS customer_markets_attended_30days_count,
    
	CASE WHEN
        DATEDIFF(
		( SELECT MIN(cma.market_date)
		  FROM customer_markets_attended AS cma
		  WHERE cma.customer_id = cp.customer_id
			AND cma.market_date > cp.market_date
		  GROUP BY cma.customer_id
		), cp.market_date) <=30
        THEN 1 ELSE 0
	END AS purchased_again_within_30_days
		
FROM farmers_market.customer_purchases AS cp
GROUP BY cp.customer_id, cp.market_date
ORDER BY cp.customer_id, cp.market_date;