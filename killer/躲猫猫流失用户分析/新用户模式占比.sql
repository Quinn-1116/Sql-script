
SELECT t2.date,
       t2.game_dnu,
       t1.gameSubType,
       t1.subtype_num
FROM
  (SELECT date,gameSubType,
               count(DISTINCT distinct_id)AS subtype_num
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2) t1
JOIN
  (SELECT date, count(DISTINCT distinct_id)AS game_dnu
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date
ORDER BY 1



--日活用户占比
SELECT date,gameSubType,
            count(DISTINCT distinct_id)AS subtype_num
FROM events
WHERE event = 'gameStart'
  AND gameTypeId = 1800
  AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
GROUP BY 1,
         2
ORDER BY 1,
         2