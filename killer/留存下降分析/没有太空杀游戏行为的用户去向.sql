-- 没有游戏行为的用户的去向

SELECT t4.date,
       t4.event,
       count(t4.distinct_id)
FROM
  (SELECT t1.date,--没有玩游戏的新用户（每天）
          t1.distinct_id
   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'register'
        AND appId = '20014'
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t1
   LEFT JOIN
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND game_played = 0
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t3 ON t1.date = t3.date
   AND t1.distinct_id = t3.distinct_id
   WHERE t3.distinct_id IS NULL
   GROUP BY 1,
            2) t2
JOIN
  (SELECT date,distinct_id,
               event
   FROM events
   WHERE date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2,
            3)t4 ON t2.distinct_id = t4.distinct_id
AND t2.date = t4.date
GROUP BY 1,
         2
ORDER BY 1,
         3 DESC






