
SELECT t3.date,
       avg(game_num)
FROM
  (SELECT t2.*--次日留存的普通模式用户

   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND gameSubType = '1'
        AND game_played = 0
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2) t1
   JOIN
     (SELECT date, distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t2 ON t1.distinct_id = t2.distinct_id
   AND datediff(t2.date,t1.date) = 1) t3
JOIN
  (SELECT date, distinct_id,
                count(distinct_id)AS game_num
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t4 ON t3.distinct_id = t4.distinct_id
AND t3.date = t4.date
GROUP BY 1
ORDER BY 1






SELECT t3.date,
       avg(game_num)
FROM
  (SELECT t2.*--次日留存的躲猫猫模式用户

   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND gameSubType = '2'
        AND game_played = 0
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2) t1
   JOIN
     (SELECT date, distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t2 ON t1.distinct_id = t2.distinct_id
   AND datediff(t2.date,t1.date) = 1) t3
JOIN
  (SELECT date, distinct_id,
                count(distinct_id)AS game_num
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t4 ON t3.distinct_id = t4.distinct_id
AND t3.date = t4.date
GROUP BY 1
ORDER BY 1