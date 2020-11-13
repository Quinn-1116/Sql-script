SELECT t1.date,
       t1.distinct_id,
       count(t2.distinct_id)AS "过去7天访问次数"
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
  (SELECT date,distinct_id,
               to_uid
   FROM events
   WHERE event = 'enterProfle'
     AND date BETWEEN '2020-07-20' AND '2020-08-02')t2 ON t1.distinct_id = t2.to_uid
AND datediff(t1.date,t2.date)<=7
GROUP BY 1,
         2
ORDER BY 1,
         3 DESC