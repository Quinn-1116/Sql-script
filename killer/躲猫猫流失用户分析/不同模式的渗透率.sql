--只玩普通模式，不玩躲猫猫模式的用户

SELECT t40.*,
       t10.`只玩普通模式的用户`,
       t20.`只玩躲猫猫模式的用户`,
       t30.`两种模式都玩的用户`
FROM
  (SELECT t1.date,
          count(t1.distinct_id)AS `只玩普通模式的用户`
   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND gameSubType = '1'
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
               2)t2 ON t1.date = t2.date
   AND t1.distinct_id =t2.distinct_id
   WHERE t2.distinct_id IS NULL
   GROUP BY 1)t10
JOIN
  (SELECT t1.date, count(t1.distinct_id)AS `只玩躲猫猫模式的用户`
   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND gameSubType = '2'
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
               2)t2 ON t1.date = t2.date
   AND t1.distinct_id =t2.distinct_id
   WHERE t2.distinct_id IS NULL
   GROUP BY 1)t20 ON t10.date = t20.date
JOIN
  (SELECT t1.date, count(t1.distinct_id)AS `两种模式都玩的用户`
   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND gameSubType = '2'
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2) t1
   JOIN
     (SELECT date, distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND gameSubType = '1'
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t2 ON t1.date = t2.date
   AND t1.distinct_id =t2.distinct_id
   GROUP BY 1)t30 ON t10.date = t30.date
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS game_dau
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1) t40 ON t10.date = t40.date
ORDER BY t40.date