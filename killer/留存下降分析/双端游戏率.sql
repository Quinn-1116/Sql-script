确认一下玩过太空杀游戏和没有玩过太空杀游戏用户在单包的次留趋势，确认下游戏率下降对留存下降的影响；
SELECT t1.date,
       count(t1.distinct_id) AS dnu,
       count(t2.distinct_id) AS login_dnu,
       count(t2.distinct_id)/count(t1.distinct_id) AS `注册-登录转化率`,
       count(t3.distinct_id) AS game_dnu,
       count(t3.distinct_id)/count(t1.distinct_id)AS `注册-游戏转化率`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20014'
     AND date between current_date() - interval 7 day and  current_date()
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20014'
     AND date between current_date() - interval 7 day and  current_date()
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date between current_date() - interval 7 day and  current_date() 
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
GROUP BY 1
order by 1


--ios的转化率

SELECT t1.date, count(t1.distinct_id) AS dnu,
                count(t2.distinct_id) AS login_dnu,
                count(t2.distinct_id)/count(t1.distinct_id) AS `注册-登录转化率`,
                count(t3.distinct_id) AS game_dnu,
                count(t3.distinct_id)/count(t1.distinct_id)AS `注册-游戏转化率`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '30015'
       AND date between current_date() - interval 7 day and  current_date() 
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '30015'
      AND date between current_date() - interval 7 day and  current_date() 
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
       AND date between current_date() - interval 7 day and  current_date() 
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
GROUP BY 1
order by 1






SELECT t1.date,
       count(t1.distinct_id) AS dnu,
       count(t3.distinct_id) AS game_dnu,
       count(t3.distinct_id)/count(t1.distinct_id)AS `注册-游戏转化率`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId in('20014','30015') 
     AND date between current_date() - interval 2 day and  current_date() - interval 1 day
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date between current_date() - interval 2 day and  current_date() - interval 1 day
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
GROUP BY 1
order by 1