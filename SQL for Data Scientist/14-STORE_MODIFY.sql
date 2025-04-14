# 新增和刪除表格
# 新增表格
CREATE TABLE farmers_market.product_units AS
(
	SELECT *
    FROM farmers_market.product
    WHERE product_qty_type = 'unit'
);

# 查詢表格
SELECT * FROM farmers_market.product_units;

# 刪除表格
DROP TABLE farmers_market.product_units;

# 新增和刪除視圖
# 新增視圖
CREATE VIEW farmers_market.product_units_vw AS
(
	SELECT *
    FROM farmers_market.product
    WHERE product_qty_type = 'unit'
);

# 查詢視圖
SELECT * FROM farmers_market.product_units_vw;

# 刪除視圖
DROP VIEW farmers_market.product_units_vw;

# 14.2
# 加入時間戳記欄位
CREATE TABLE farmers_market.product_units AS
(
	SELECT *,
    CURRENT_TIMESTAMP AS snapshot_timestamp
    FROM farmers_market.product
    WHERE product_qty_type = 'unit'
);

SELECT * FROM farmers_market.product_units;

# 用INSERT INTO 插入新的列資料
INSERT INTO farmers_market.product_units
	(product_id, product_name, product_size, product_category_id,
     product_qty_type, snapshot_timestamp)
	SELECT
		product_id,
        product_name,
        product_size,
        product_category_id,
        product_qty_type,
        CURRENT_TIMESTAMP
	FROM farmers_market.product
    WHERE product_id = 23;

SELECT * FROM farmers_market.product_units;

# 用 DELETE 刪除符合條件的列資料
DELETE FROM farmers_market.product_units
WHERE product_id = 23
	AND snapshot_timestamp = '2025-04-14 16:23:31';
    
SELECT * FROM farmers_market.product_units;

# 用 UPDATE 更新現有的列資料
# 更新資料前 先將資料存一份快照
CREATE TABLE farmers_market.vendor_booth_log AS
(
	SELECT
		vba.*,
        b.booth_type,
        v.vendor_name,
        CURRENT_TIMESTAMP AS snapshot_timestamp
    FROM farmers_market.vendor_booth_assignments AS vba
		INNER JOIN farmers_market.vendor AS v
			ON vba.vendor_id = v.vendor_id
		INNER JOIN farmers_market.booth AS b
			ON vba.booth_number = b.booth_number
	WHERE market_date >= '2020-10-01'
); 

SELECT *
FROM farmers_market.vendor_booth_log;

# 更新2020-10-10 供應商8的攤位編號為11 
UPDATE farmers_market.vendor_booth_assignments
SET booth_number = 11
WHERE vendor_id = 8 and market_date = '2020-10-10';

# 刪除2020-10-10 供應商7 的列資料
DELETE FROM farmers_market.vendor_booth_assignments
WHERE vendor_id = 7 and market_date = '2020-10-10';

SELECT *
FROM farmers_market.vendor_booth_assignments
WHERE market_date = '2020-10-10';

# 將剛剛的改動插入至log中
INSERT INTO farmers_market.vendor_booth_log
    (vendor_id, booth_number, market_date, booth_type,
     vendor_name, snapshot_timestamp)
SELECT
    vba.vendor_id,
    vba.booth_number,
    vba.market_date,
    b.booth_type,
    v.vendor_name,
    CURRENT_TIMESTAMP AS snapshot_timestamp
FROM farmers_market.vendor_booth_assignments AS vba
    INNER JOIN farmers_market.vendor AS v
      ON vba.vendor_id = v.vendor_id
    INNER JOIN farmers_market.booth AS b
      ON vba.booth_number = b.booth_number
WHERE market_date >= '2020-10-01';

SELECT *
FROM farmers_market.vendor_booth_log;

# practice
# 如果是VIEW 中的CURRENT_TIMESTAMP 會是什麼
# 會是每次執行程式的時間 因為VIEW 不會存取資料

# 查詢log 表格 最新的2020-10-03的攤位資料
SELECT x.* FROM
(
  SELECT
    vendor_id,
    booth_number,
    market_date,
    snapshot_timestamp,
    MAX(snapshot_timestamp) OVER (PARTITION BY
    vendor_id, booth_number) AS max_timestamp_in_filter
  FROM farmers_market.vendor_booth_log
  WHERE DATE(market_date) <= '2020-10-04'
) AS x

WHERE x.snapshot_timestamp = x.max_timestamp_in_filter
	AND market_date = '2020-10-03';