玩家之前打过普通分场 后来又第一次打了躲猫猫，game_played会不会记成0？
SELECT t2.distinct_id,
       t1.game_played,
       t1.time,
       t2.game_played,
       t2.time
FROM
  (SELECT date,distinct_id,
               time,
               game_played
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND gameSubType = '1'
     AND date BETWEEN '2020-10-24' AND current_date()
   GROUP BY 1,
            2,
            3,
            4) t1
JOIN
  (SELECT date,distinct_id,
               game_played,
               time
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND gameSubType = '2'
     AND date BETWEEN '2020-10-24' AND current_date()
   GROUP BY 1,
            2,
            3,
            4) t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date)=1
ORDER BY  t2.game_played,



SELECT distinct_id,count(distinct_id) from events where event = 'gameStart' and gameTypeId = 1800
and date = '2020-10-25' and distinct_id = '123118470'