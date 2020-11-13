--留存

SELECT t10.*,
       t20.*
FROM
  (SELECT t4.date,
          --留存下来的躲猫猫用户的分场选择
          t4.gameSubType,
          count(t4.distinct_id)AS `分场用户数`
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
     (SELECT date,gameSubType,
                  --不同分场的uid

                  distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2,
               3)t4 ON t3.distinct_id = t4.distinct_id
   AND t3.date = t4.date
   GROUP BY 1,
            2)t10
JOIN
  (SELECT t6.date,count(t6.distinct_id)AS `次日留存总人数(躲猫猫模式)`--留存下来的躲猫猫用户的总用户数
   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND gameSubType = '2'
        AND game_played = 0
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2) t5
   JOIN
     (SELECT date, distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t6 ON t5.distinct_id = t6.distinct_id
   AND datediff(t6.date,t5.date) = 1
   GROUP BY 1)t20 ON t10.date = t20.date
ORDER BY t10.date









SELECT t10.*,
       t20.*
FROM
  (SELECT t4.date,--留存下来的普通用户的分场选择
          t4.gameSubType,
          count(t4.distinct_id)AS `分场用户数`
   FROM
     (SELECT t2.*--次日留存的普通模式新用户

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
     (SELECT date,gameSubType,
                  --不同分场的uid

                  distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2,
               3)t4 ON t3.distinct_id = t4.distinct_id
   AND t3.date = t4.date
   GROUP BY 1,
            2)t10
JOIN
  (SELECT t6.date,
          count(t6.distinct_id)AS `次日留存总人数(普通模式)`--留存下来的普通用户的总用户数

   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND gameSubType = '1'
        AND game_played = 0
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2) t5
   JOIN
     (SELECT date, distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t6 ON t5.distinct_id = t6.distinct_id
   AND datediff(t6.date,t5.date) = 1
   GROUP BY 1)t20 ON t10.date = t20.date
ORDER BY t10.date