# 5.2
# LEFT JOIN 左外部連結
SELECT 
	p.product_id,
    p.product_name,
    pc.product_category_id,
    pc.product_category_name
FROM farmers_market.product as p
	LEFT JOIN farmers_market.product_category as pc
		on p.product_category_id =
		   pc.product_category_id
ORDER BY pc.product_category_name, p.product_name;

# 5.3
# RIGHT JOIN 右外部連結
SELECT 
	p.product_id,
    p.product_name,
    pc.product_category_id,
    pc.product_category_name
FROM farmers_market.product as p
	RIGHT JOIN farmers_market.product_category as pc
		on p.product_category_id =
		   pc.product_category_id
ORDER BY pc.product_category_name, p.product_name;

# 5.4
# INNER JOIN 內部連結
SELECT 
	p.product_id,
    p.product_name,
    pc.product_category_id,
    pc.product_category_name
FROM farmers_market.product as p
	JOIN farmers_market.product_category as pc
		on p.product_category_id =
		   pc.product_category_id
ORDER BY pc.product_category_name, p.product_name;

# 5.5
# 比較LEFT RIGHT INNER JOIN 的差異
# LEFT JOIN 找出有留資料但沒有購物的顧客
SELECT c.*
FROM farmers_market.customer as c
	LEFT JOIN farmers_market.customer_purchases as cp
		ON c.customer_id = cp.customer_id
WHERE cp.customer_id IS NULL;

# RIGHT JOIN 列出所有購買紀錄 (不會顯示沒有購買的顧客資料)
SELECT *
FROM farmers_market.customer as c
	RIGHT JOIN farmers_market.customer_purchases as cp
		ON c.customer_id = cp.customer_id;
        
# INNER JOIN 兩邊都有的資料 這邊結果會跟RIGHT JOIN一樣
SELECT *
FROM farmers_market.customer as c
	INNER JOIN farmers_market.customer_purchases as cp
		ON c.customer_id = cp.customer_id;
        
# 5.6 篩選連結資料的陷阱
# LEFT JOIN 但對右表格做篩選時 會把沒有購買紀錄的人篩掉
# 要再多加 IS NULL
SELECT c.*, cp.market_date
FROM farmers_market.customer AS c
LEFT JOIN farmers_market.customer_purchases AS cp
	 ON c.customer_id = cp.customer_id
WHERE (cp.market_date <> '2019-04-03' OR cp.market_date IS NULL);

# 取得唯一名單
SELECT DISTINCT c.*
FROM farmers_market.customer AS c
LEFT JOIN farmers_market.customer_purchases AS cp
	 ON c.customer_id = cp.customer_id
WHERE (cp.market_date <> '2019-04-03' OR cp.market_date IS NULL);

# 5.7 JOIN 兩個以上的表格
SELECT
	b.booth_number,
    b.booth_type,
    vba.market_date,
    v.vendor_id,
    v.vendor_name,
    v.vendor_type
FROM farmers_market.booth AS b
	LEFT JOIN farmers_market.vendor_booth_assignments AS vba
		ON b.booth_number = vba.booth_number
	LEFT JOIN farmers_market.vendor AS v
		ON vba.vendor_id = v.vendor_id
ORDER BY b.booth_number, vba.market_date;

# practice
# INNER JOIN vendor 與 vendor_booth_assignment 表格以vendor_name, market_date 升冪排序
SELECT *
FROM farmers_market.vendor AS v
	INNER JOIN farmers_market.vendor_booth_assignments AS vba
		ON v.vendor_id = vba.vendor_id
ORDER BY v.vendor_name, vba.market_date;

# 改寫為LEFT JOIN 但輸出結果相同
SELECT *
FROM farmers_market.customer AS c
	RIGHT JOIN farmers_market.customer_purchases AS cp
		ON c.customer_id = cp.customer_id;

SELECT c.*, cp.*
FROM farmers_market.customer_purchases AS cp
	LEFT JOIN farmers_market.customer AS c
		ON  cp.customer_id = c.customer_id;