SELECT t1.date,
       count(t1.distinct_id)AS `认证成功的新注册用户`,
       count(t4.distinct_id)/count(t1.distinct_id) AS `认证成功的新注册用户的R2`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20014'
     AND regist_type NOT in('celln', 'celln_direct')
     AND date BETWEEN '2020-10-23' AND current_date()
   GROUP BY 1,
            2)t1
JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'action'--防沉迷实名弹窗

     AND appId = '20014'
     AND date BETWEEN '2020-10-23' AND current_date()
     AND op_type = 'anti_indulgence_popup'
     AND pop_type = 'verified_mode_popup'
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id =t2.distinct_id
JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'regRealName'
     AND appId = '20014'
     AND date BETWEEN '2020-10-23' AND current_date()
     AND RESULT= 'success'
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
AND t2.distinct_id = t3.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20014'
     AND date BETWEEN '2020-10-23' AND current_date()
     AND RESULT= 'success'
   GROUP BY 1,
            2)t4 ON t1.distinct_id = t4.distinct_id
AND datediff(t4.date,t1.date) = 1
GROUP BY 1
ORDER BY 1