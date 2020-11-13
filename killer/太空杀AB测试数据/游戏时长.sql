SELECT t2.date,
       t2.distinct_id,
       t2.duration
FROM
  (SELECT second_id
   FROM users
   WHERE reg_channelId IN ('114',
                           '130')
   GROUP BY 1) t1
JOIN
  (SELECT date, distinct_id,
                sum(duration/60000)AS duration
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-19' AND CURRENT_DATE()
   GROUP BY 1,
            2)t2 ON t1.second_id = t2.distinct_id




