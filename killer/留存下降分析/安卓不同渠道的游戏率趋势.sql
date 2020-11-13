--各渠道的DNU、DAU、游戏率、人均游戏时长、人均游戏次数
--11月4号开始投放

SELECT t1.date,
       CASE
           WHEN t1.channelId = '1290' THEN 'tks_douyin21'
           WHEN t1.channelId = '1291' THEN 'tks_douyin22'
           WHEN t1.channelId = '1292' THEN 'tks_douyin23'
           WHEN t1.channelId = '1293' THEN 'tks_douyin24'
           WHEN t1.channelId = '1294' THEN 'tks_douyin25'
           WHEN t1.channelId = '1295' THEN 'tks_douyin26'
           WHEN t1.channelId = '1296' THEN 'tks_douyin27'
           WHEN t1.channelId = '1297' THEN 'tks_douyin28'
           WHEN t1.channelId = '1298' THEN 'tks_douyin29'
           WHEN t1.channelId = '1299' THEN 'tks_douyin30'
       END AS "渠道类型",
       t1.channelId,
       count(t1.distinct_id) AS `渠道注册用户数`,
       count(t2.distinct_id)AS `渠道游戏用户数`,
       count(t1.distinct_id)-count(t2.distinct_id)AS `未游戏用户数`,
       count(t2.distinct_id)/count(t1.distinct_id)AS `渠道游戏率`,
       avg(t3.duration) AS `渠道人均游戏时长`,
       avg(t3.game_num)AS `渠道人均游戏次数`
FROM
  (SELECT date,distinct_id,
               channelId
   FROM events
   WHERE event = 'register'
     AND appId = '20014'
     AND date BETWEEN '2020-11-04' AND current_date()
   GROUP BY 1,
            2,
            3)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date BETWEEN '2020-11-04' AND current_date()
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
LEFT JOIN
  (SELECT date,distinct_id,
               sum(duration)/60000 AS duration,
               count(distinct_id)AS game_num
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date BETWEEN '2020-11-04' AND current_date()
   GROUP BY 1,
            2)t3 ON t1.distinct_id = t3.distinct_id
AND t1.date = t2.date
GROUP BY 1,
         2,
         3
ORDER BY 2,
         4 DESC