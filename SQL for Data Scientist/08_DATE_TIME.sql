# 8.1 
# 建立datetime 資料型別欄位
CREATE TABLE farmers_market.datetime_demo AS
(
 SELECT 
	market_date,
    market_start_time,
    market_end_time,
    
    str_to_date(CONCAT(market_date, ' ', market_start_time),
		'%Y-%m-%d%h:%i %p') AS market_start_datetime,
        
	str_to_date(CONCAT(market_date, ' ', market_end_time),
		'%Y-%m-%d%h:%i %p') AS market_end_datetime
    
 FROM farmers_market.market_date_info
);

# 8.2
# 提取datetime 局部數值 EXTRACT DATE TIME
# 提取datetime 單一數值的EXTRACT 函數
SELECT market_start_datetime,
	EXTRACT(DAY FROM market_start_datetime) AS mktsrt_day,
    EXTRACT(MONTH FROM market_start_datetime) AS mktsrt_month,
    EXTRACT(YEAR FROM market_start_datetime) AS mktsrt_year,
    EXTRACT(HOUR FROM market_start_datetime) AS mktsrt_hour,
    EXTRACT(MINUTE FROM market_start_datetime) AS mktsrt_minute
FROM farmers_market.datetime_demo
WHERE market_start_datetime = '2019-03-02 08:00:00';

# 提取日期部分或時間部份的 DATE TIME 函數
SELECT market_start_datetime,
	DATE(market_start_datetime) AS mktsrt_date,
    TIME(market_start_datetime) AS mktsrt_time
FROM farmers_market.datetime_demo
WHERE market_start_datetime = '2019-03-02 08:00:00';

# 往後取得結束時間的DATE_ADD 函數
SELECT market_start_datetime,
	DATE_ADD(market_start_datetime, INTERVAL 30 DAY)
		AS mktstrt_date_plus_30days
FROM farmers_market.datetime_demo
WHERE market_start_datetime = '2019-03-02 08:00:00';

# 得到反向時間的 DATE_SUB 函數
SELECT market_start_datetime,
	DATE_ADD(market_start_datetime, INTERVAL -30 DAY)
		AS mktstrt_date_plus_neg30days,
	DATE_SUB(market_start_datetime, INTERVAL 30 DAY)
		AS mktstrt_date_minus_30days
FROM farmers_market.datetime_demo
WHERE market_start_datetime = '2019-03-02 08:00:00';

# 8.4
# 計算時間差異 DATEDIFF
SELECT
	x.first_market,
    x.last_market,
    DATEDIFF(x.last_market, x.first_market)
		AS days_first_to_last
FROM
(
	SELECT
		min(market_start_datetime) first_market,
		max(market_start_datetime) last_market
	FROM farmers_market.datetime_demo
) AS x;

# 8.5
# 指定時間差異單位 TIMESTAMPDIFF
SELECT market_start_datetime, market_end_datetime,
	TIMESTAMPDIFF(HOUR, market_start_datetime, market_end_datetime)
		AS market_duration_hours,
	TIMESTAMPDIFF(MINUTE, market_start_datetime, market_end_datetime)
		AS market_duration_mins
FROM farmers_market.datetime_demo;

# 8.6
# 用聚合函數與窗口函數處理 datetime 資料
# 找出顧客最早與最近的消費日期
SELECT
	customer_id,
	MIN(market_date) AS first_purchase,
    MAX(market_date) AS last_purchase,
    COUNT(DISTINCT market_date) AS count_of_purchase_dates
FROM farmers_market.customer_purchases
WHERE customer_id = 1
GROUP BY customer_id;

# 計算最早與最近消費日期相隔幾天
SELECT
	customer_id,
	MIN(market_date) AS first_purchase,
    MAX(market_date) AS last_purchase,
    COUNT(DISTINCT market_date) AS count_of_purchase_dates,
    DATEDIFF(MAX(market_date), MIN(market_date))
		AS days_between_first_last_purchase
FROM farmers_market.customer_purchases
GROUP BY customer_id;

# 最近一次消費離現在幾天
SELECT
	customer_id,
	MIN(market_date) AS first_purchase,
    MAX(market_date) AS last_purchase,
    COUNT(DISTINCT market_date) AS count_of_purchase_dates,
    DATEDIFF(MAX(market_date), MIN(market_date))
		AS days_between_first_last_purchase,
    DATEDIFF(CURDATE(), MAX(market_date))
		AS days_since_last_purchase
FROM farmers_market.customer_purchases
GROUP BY customer_id;

# 將本次與下次消費日期並列 並算出每兩次消費的間隔天數
SELECT
	x.customer_id,
    x.market_date,
    RANK() OVER (PARTITION BY x.customer_id
		ORDER BY x.market_date) AS purchase_number,
	LEAD(x.market_date, 1)  OVER (PARTITION BY x.customer_id
		ORDER BY x.market_date) AS next_purchase,
	DATEDIFF(LEAD(x.market_date, 1)  OVER 
			(PARTITION BY x.customer_id
			 ORDER BY x.market_date), x.market_date)
             AS days_between_purchase
FROM
(
	SELECT DISTINCT customer_id, market_date
	FROM farmers_market.customer_purchases
	WHERE customer_id = 1
) AS x;

# 巢狀查詢
SELECT
	a.customer_id,
    a.market_date AS first_purchase,
    a.next_purchase AS second_purchase,
    DATEDIFF(a.next_purchase, a.market_date)
		AS time_between_1st_2nd_purchase
FROM
(
	SELECT
		x.customer_id,
		x.market_date,
		RANK() OVER (PARTITION BY x.customer_id
			ORDER BY x.market_date) AS purchase_number,
		LEAD(x.market_date, 1)  OVER (PARTITION BY x.customer_id
			ORDER BY x.market_date) AS next_purchase
	FROM
	(
		SELECT DISTINCT customer_id, market_date
		FROM farmers_market.customer_purchases
	) AS x
) AS a
WHERE customer_id = 1;

# 激勵某一段時間很少消費的顧客回購
SELECT
	x.customer_id,
    COUNT(x.market_date) AS market_count
FROM
(
	SELECT DISTINCT customer_id, market_date
	FROM farmers_market.customer_purchases
	WHERE DATEDIFF('2020-10-31', market_date) BETWEEN 0 AND 30
) AS x
GROUP BY x.customer_id
HAVING COUNT(market_date) = 1;

# practice
# 輸出每一筆購買紀錄 包含顧客編號 年分 月份
SELECT
	customer_id,
    EXTRACT(YEAR FROM market_date) AS purchase_year,
    EXTRACT(MONTH FROM market_date) AS purchase_month  
FROM farmers_market.customer_purchases;

# 查詢2020-10-10 回算兩周內的所有消費紀錄 兩周前的日期放sales_since_date
# 算出每筆銷售額 加總放在total_sales
SELECT
	MIN(market_date) AS sales_since_date,
	SUM(quantity * cost_to_customer_per_qty) AS total_sales
FROM farmers_market.customer_purchases
WHERE TIMESTAMPDIFF(DAY, market_date, '2020-10-10') BETWEEN 0 AND 14;

SELECT
	MIN(market_date) AS sales_since_date,
	SUM(quantity * cost_to_customer_per_qty) AS total_sales
FROM farmers_market.customer_purchases
WHERE DATEDIFF('2020-10-10', market_date) BETWEEN 0 AND 14;

# 用 CURDATE() 取代 2020-10-10
# 基本上沒資料 因為超過兩周以上
SELECT
	MIN(market_date) AS sales_since_date,
	SUM(quantity * cost_to_customer_per_qty) AS total_sales
FROM farmers_market.customer_purchases
WHERE DATEDIFF(CURDATE(), market_date) BETWEEN 0 AND 14;

# 用DAYNAME() 回傳星期 放入calculated_market_day
# 比對market_day欄位 結果回傳day_verified
SELECT
	market_date,
    market_day,
    DAYNAME(market_date) AS calculated_market_day,
    CASE 
		WHEN market_day = DAYNAME(market_date)
        THEN '正確' ELSE '錯誤'
	END AS day_verified
FROM farmers_market.market_date_info;
