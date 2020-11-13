SELECT t1.date,
       t1.distinct_id,
       count(t2.date)AS "7日登录天数"
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'membership'
     AND date BETWEEN '2020-07-27' AND '2020-08-09'
     AND SOURCE in('activity_membership_aim3_adv','activity_membership_aim3_notice')
     AND to_uid_type IN (1,
                         2)
     AND misc IN ('open',
                  'renew')
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND date BETWEEN '2020-07-20' AND '2020-08-02'
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t1.date,t2.date)<=7
AND datediff(t1.date,t2.date)>=1
GROUP BY 1,
         2