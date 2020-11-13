-- 游戏属性：游戏时长、游戏局数、游戏类型（匹配or搜索房间进入）

SELECT t1.distinct_id,
       t1.pay,
       t2."游戏局数",
       t2.duration
FROM
  (SELECT distinct_id,
          sum(pay) AS pay
   FROM events
   WHERE event = 'pay'
     AND date BETWEEN '2020-10-16' AND current_date()
     AND appId IN ('20014',
                   '30015')
   GROUP BY 1) t1
LEFT JOIN
  (SELECT distinct_id,
          count(distinct_id)AS "游戏局数",
          sum(duration/60000)AS duration
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date >='2020-10-16'
     AND time >'2020-10-16 12:00:00'
   GROUP BY 1)t2 ON t1.distinct_id = t2.distinct_id


  SELECT distinct_id,
          count(distinct_id)AS "游戏局数",
          sum(duration/60000)AS duration
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date >='2020-10-16'
     AND time >'2020-10-16 12:00:00'
   GROUP BY 1