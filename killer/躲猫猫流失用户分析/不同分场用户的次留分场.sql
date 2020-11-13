-- 玩过普通模式和躲猫猫模式的用户后续在两种模式里的回流率

SELECT t4.date,
       t3.hide_num,
       t4.gameSubType,
       t4.subtype_num
FROM
  (SELECT t1.date,
          t2.gameSubType,
          count(t2.distinct_id)AS subtype_num
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
     (SELECT date, gameSubType,
                   distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2,
               3)t2 ON t1.distinct_id = t2.distinct_id
   AND datediff(t2.date,t1.date) = 1
   GROUP BY 1,
            2)t4
LEFT JOIN
  (SELECT date,count(DISTINCT distinct_id)AS hide_num
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND gameSubType = '2'
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1)t3 ON t4.date = t3.date
WHERE t4.gameSubType IS NOT NULL
ORDER BY 1,3




SELECT t4.date,
       t3.common_num,
       t4.gameSubType,
       t4.subtype_num
FROM
  (SELECT t1.date,
          t2.gameSubType,
          count(t2.distinct_id)AS subtype_num
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
     (SELECT date, gameSubType,
                   distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2,
               3)t2 ON t1.distinct_id = t2.distinct_id
   AND datediff(t2.date,t1.date) = 1
   GROUP BY 1,
            2)t4
LEFT JOIN
  (SELECT date,count(DISTINCT distinct_id)AS common_num
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND gameSubType = '1'
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1)t3 ON t4.date = t3.date
WHERE t4.gameSubType IS NOT NULL
ORDER BY 1,3