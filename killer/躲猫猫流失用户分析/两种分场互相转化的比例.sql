
SELECT t3.date,
       count(t3.distinct_id)AS `躲猫猫模式次日流失用户数`,
       count(t4.distinct_id)AS `躲猫猫模式次日流失后去了普通模式的用户`
FROM
  (SELECT t1.date,
          t1.distinct_id
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
   LEFT JOIN
     (SELECT date, distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND gameSubType = '2'
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t2 ON t1.distinct_id = t2.distinct_id
   AND datediff(t2.date,t1.date) =1
   WHERE t2.distinct_id IS NULL
   GROUP BY 1,
            2) t3
LEFT JOIN
  (SELECT date, distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND gameSubType = '1'
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t4 ON t3.distinct_id = t4.distinct_id
AND datediff(t4.date,t3.date) = 1
GROUP BY 1
ORDER BY 1





SELECT t3.date,
       count(t3.distinct_id)AS `普通模式次日流失用户数`,
       count(t4.distinct_id)AS `普通模式次日流失后去了躲猫猫模式的用户`,
       count(t4.distinct_id)/count(t3.distinct_id)
FROM
  (SELECT t1.date,
          t1.distinct_id
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
     (SELECT date, distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND gameSubType = '1'
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t2 ON t1.distinct_id = t2.distinct_id
   AND datediff(t2.date,t1.date) =1
   WHERE t2.distinct_id IS NULL
   GROUP BY 1,
            2) t3
LEFT JOIN
  (SELECT date, distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND gameSubType = '2'
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t4 ON t3.distinct_id = t4.distinct_id
AND datediff(t4.date,t3.date) = 1
GROUP BY 1
ORDER BY 1