SELECT t1.date,
       count(t1.distinct_id),
       count(t2.distinct_id),
       (count(t2.distinct_id)/count(t1.distinct_id))AS r_1
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
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
ORDER BY 1
