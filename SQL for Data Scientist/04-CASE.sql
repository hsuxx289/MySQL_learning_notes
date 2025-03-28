# 4.1
# 個別處理每個分支
# 先查詢有哪些供應商類別
SELECT DISTINCT vendor_type
FROM farmers_market.vendor;
# 將含fresh的特別標記
SELECT
	vendor_id,
    vendor_name,
    vendor_type,
    CASE
		WHEN LOWER(vendor_type) LIKE '%fresh%'
			THEN 'Fresh Produce'
		ELSE 'Other'
	END AS vendor_type_condensed
FROM farmers_market.vendor;

# 4.2
# 以 CASE 產生二元欄位 (Binary Flags)
# 分出平假日
SELECT
	market_date,
    market_day,
    CASE
		WHEN market_day = 'Saturday' OR market_day = 'Sunday'
			THEN 1 ELSE 0
		END AS weekend_flag
FROM farmers_market.market_date_info
LIMIT 5;

# 4.3
# 將連續數值用 CASE 分出區間
# 交易額以50為界劃分
SELECT
	market_date,
    customer_id,
    vendor_id,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS price,
    CASE
		WHEN quantity * cost_to_customer_per_qty > 50
			THEN 1 ELSE 0
	END AS price_over_50
FROM farmers_market.customer_purchases;

# 分出多個區間並顯示區間最小值
SELECT
	market_date,
    customer_id,
    vendor_id,
    ROUND(quantity * cost_to_customer_per_qty, 2) AS price,
    CASE
		WHEN quantity * cost_to_customer_per_qty < 5.00
			THEN 'Under $5'
		WHEN quantity * cost_to_customer_per_qty < 10.00
			THEN '$5-$9.99'
		WHEN quantity * cost_to_customer_per_qty < 20.00
			THEN '$10-$19.99'
		WHEN quantity * cost_to_customer_per_qty >= 20.00
			THEN '$20 and up'
	END AS price_bin,
    CASE
		WHEN quantity * cost_to_customer_per_qty < 5.00
			THEN 0
		WHEN quantity * cost_to_customer_per_qty < 10.00
			THEN 5
		WHEN quantity * cost_to_customer_per_qty < 20.00
			THEN 10
		WHEN quantity * cost_to_customer_per_qty >= 20.00
			THEN 20
	END AS price_bin_lower_end
FROM farmers_market.customer_purchases
LIMIT 10;

# 4.4
# 透過 CASE 進行分類編碼
SELECT
	booth_number,
    booth_price_level,
    CASE
		WHEN booth_price_level = 'A' THEN 1
        WHEN booth_price_level = 'B' THEN 2
        WHEN booth_price_level = 'C' THEN 3
	END AS booth_price_level_numeric
FROM farmers_market.booth
LIMIT 5;

# One-Hot 編碼(沒有高低之分的特徵)
SELECT
	vendor_id,
    vendor_type,
    CASE WHEN vendor_type = 'Arts & Jewelry'
		THEN 1 
        ELSE 0
	END AS Arts_Jewelry,
    CASE WHEN vendor_type = 'Eggs & Meats'
		THEN 1 
        ELSE 0
	END AS Eggs_Meats,
    CASE WHEN vendor_type = 'Fresh Focused'
		THEN 1 
        ELSE 0
	END AS Fresh_Focused,
    CASE WHEN vendor_type = 'Fresh Variety: Veggies & More'
		THEN 1 
        ELSE 0
	END AS Fresh_Variety,
    CASE WHEN vendor_type = 'Prepared Foods'
		THEN 1 
        ELSE 0
	END AS Prepared_Foods
FROM farmers_market.vendor;

# 4.5
# 區分本地customer
SELECT
	customer_id,
    CASE
		WHEN customer_zip = '22801' THEN 'Local'
        ELSE 'Not Local'
	END customer_location_type
FROM farmers_market.customer
LIMIT 10;

# practice
# 區分是unit 或是 bulk
SELECT
	product_id,
    product_name,
    CASE 
		WHEN product_qty_type = 'unit'
			THEN 'unit' ELSE 'bulk'
	END AS prod_qty_type_condensed
FROM farmers_market.product;

# 區分出pepper 的產品
SELECT
	product_id,
    product_name,
    CASE 
		WHEN product_qty_type = 'unit'
			THEN 'unit' ELSE 'bulk'
	END AS prod_qty_type_condensed,
    CASE
		WHEN LOWER(product_name) LIKE '%pepper%'
			THEN 1 ELSE 0
	END AS pepper_flag
FROM farmers_market.product;