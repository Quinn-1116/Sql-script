SELECT t1.channelId,
       count(t1.distinct_id)AS register_num,
       count(t2.distinct_id)AS login_num,
       count(t2.distinct_id)/count(t1.distinct_id)AS r_1
FROM
  (SELECT date,distinct_id,
               channelId
   FROM events
   WHERE event = 'register'
     AND appId = '20014'
     AND date = current_date() - interval 2 DAY
   GROUP BY 1,
            2,
            3) t1
LEFT JOIN
  (SELECT date,distinct_id,
               channelId
   FROM events
   WHERE event = 'login'
     AND appId = '20014'
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2,
            3)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
AND t1.channelId = t2.channelId
GROUP BY 1
ORDER BY 4 DESC