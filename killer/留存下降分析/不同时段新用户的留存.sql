
SELECT t1.date,
       t1.hour,
       count(t1.distinct_id)AS `DNU`,
       count(t2.distinct_id) AS `login_r1`,
       count(t2.distinct_id)/count(t1.distinct_id) AS `app_r1_rate`,
       count(t3.distinct_id) AS `game_r1`,
       count(t3.distinct_id)/count(t1.distinct_id)AS `game_r1_rate`
FROM
  (SELECT date, hour(time)AS hour,
                distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20014'
     AND date BETWEEN current_date() - interval 30 DAY AND current_date()
   GROUP BY 1,
            2,
            3)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20014'
     AND date BETWEEN current_date() - interval 30 DAY AND current_date()
   GROUP BY 1,
            2)t2 ON datediff(t2.date,t1.date) = 2
AND t1.distinct_id = t2.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date BETWEEN current_date() - interval 30 DAY AND current_date()
   GROUP BY 1,
            2)t3 ON datediff(t3.date,t1.date) = 2
AND t1.distinct_id = t3.distinct_id
GROUP BY 1,
         2
ORDER BY 1,
         2