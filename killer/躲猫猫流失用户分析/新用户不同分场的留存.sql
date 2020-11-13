SELECT t4.date,
       t4.subtype_num,
       t3.gap,
       t3.`次日留存用户数`,
       t3.`次日留存用户数`/t4.subtype_num AS Retention
FROM
  (SELECT t1.date,
          datediff(t2.date,t1.date) AS gap,
          count(t2.distinct_id)AS `次日留存用户数`
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
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t2 ON t1.distinct_id = t2.distinct_id
   AND datediff(t2.date,t1.date) BETWEEN 1 AND 7
   GROUP BY 1,
            2
   ORDER BY 1,
            2)t3
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS subtype_num
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND gameSubType = '1'
     AND game_played = 0
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1)t4 ON t3.date = t4.date
ORDER BY 1,
         3





SELECT t4.date, t4.subtype_num,
                t3.gap,
                t3.`次日留存用户数`,
                t3.`次日留存用户数`/t4.subtype_num AS Retention
FROM
  (SELECT t1.date, datediff(t2.date,t1.date) AS gap,
                   count(t2.distinct_id)AS `次日留存用户数`
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
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t2 ON t1.distinct_id = t2.distinct_id
   AND datediff(t2.date,t1.date) BETWEEN 1 AND 7
   GROUP BY 1,
            2
   ORDER BY 1,
            2)t3
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS subtype_num
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND gameSubType = '2'
     AND game_played = 0
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1)t4 ON t3.date = t4.date
ORDER BY 1,
         3