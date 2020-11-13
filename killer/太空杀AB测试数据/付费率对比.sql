SELECT 
count(t2.distinct_id),
count(t1.second_id),

count(t2.distinct_id)/count(t1.second_id) AS `付费率`
FROM
  (SELECT second_id
   FROM users
   WHERE reg_channelId IN ('114',
                           '130')
     AND FROM_UNIXTIME(CAST($signup_time/1000 AS BIGINT)) >='2020-10-19'
   GROUP BY 1) t1
left JOIN
  (SELECT distinct_id
   FROM events
   WHERE event = 'pay'
     AND date BETWEEN '2020-10-19' AND CURRENT_DATE()
   GROUP BY 1)t2 ON t1.second_id = t2.distinct_id




SELECT 

count(t2.distinct_id),
count(t1.second_id),
count(t2.distinct_id)/count(t1.second_id) AS `付费率`
FROM
  (SELECT second_id
   FROM users
   WHERE reg_channelId IN ('131',
                           '122',
                           '113',
                           '111',
                           '127',
                           '112',
                           '125',
                           '116')
     AND FROM_UNIXTIME(CAST($signup_time/1000 AS BIGINT)) >='2020-10-19'
   GROUP BY 1) t1
LEFT JOIN
  (SELECT distinct_id
   FROM events
   WHERE event = 'pay'
     AND date BETWEEN '2020-10-19' AND CURRENT_DATE()
   GROUP BY 1)t2 ON t1.second_id = t2.distinct_id