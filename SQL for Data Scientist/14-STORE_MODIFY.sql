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