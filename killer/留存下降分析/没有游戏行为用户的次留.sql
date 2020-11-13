SELECT t2.date,
       count(t2.distinct_id) AS `game_amount`,
       count(t4.distinct_id) AS `game_r1`,
       count(t4.distinct_id) /count(t2.distinct_id) as `game_r1_rate`
FROM
  (SELECT t1.date,
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
   WHERE t3.distinct_id IS NOT NULL
   GROUP BY 1,
            2) t2
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20014'
     AND date BETWEEN '2020-10-21' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t4 ON t2.distinct_id = t4.distinct_id
AND datediff(t4.date,t2.date) = 1
GROUP BY 1
ORDER BY 1




SELECT t2.date,
       count(t2.distinct_id) AS `not_game_amount`,
       count(t4.distinct_id) AS `not_game_r1`,
       count(t4.distinct_id) /count(t2.distinct_id) as `not_game_r1_rate`
FROM
  (SELECT t1.date,--没有玩游戏的新用户
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
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20014'
     AND date BETWEEN '2020-10-21' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t4 ON t2.distinct_id = t4.distinct_id
AND datediff(t4.date,t2.date) = 1
GROUP BY 1
ORDER BY 1