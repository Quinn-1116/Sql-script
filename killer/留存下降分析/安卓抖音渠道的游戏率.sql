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
       count(t1.distinct_id) AS `register_num`,
       count(t2.distinct_id)AS `game_num`,
       count(t1.distinct_id)-count(t2.distinct_id)AS `未游戏用户数`,
       count(t2.distinct_id)/count(t1.distinct_id)AS `game_rate`
FROM
  (SELECT date,distinct_id,
               channelId
   FROM events
   WHERE event = 'register'
     AND appId = '20014'
     AND date = current_date()
   GROUP BY 1,
            2,
            3)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date = current_date()
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
GROUP BY 1,
         2,
         3
ORDER BY 2