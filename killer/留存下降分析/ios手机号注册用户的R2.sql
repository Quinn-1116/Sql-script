SELECT t1.date,
       count(t1.distinct_id)as `手机号新增注册用户数`,
       count(t2.distinct_id)as `次日留存用户数`,
       count(t2.distinct_id)/count(t1.distinct_id)AS `R2`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'--注册

     AND regist_type in('celln', 'celln_direct')
     AND appId = '30015'
     AND date BETWEEN '2020-10-23' AND current_date()
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'--游戏开始

     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-24' AND current_date()
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
ORDER BY 1