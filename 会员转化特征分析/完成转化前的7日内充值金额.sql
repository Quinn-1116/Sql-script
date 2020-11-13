SELECT t1.date,
       t1.distinct_id,
       t2.date,
       t2.pay
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
               sum(pay)AS pay
   FROM events
   WHERE event = 'pay'
     AND date BETWEEN '2020-07-20' AND '2020-08-02'
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t1.date,t2.date)<=7
AND datediff(t1.date,t2.date)>=0
GROUP BY 1,
         2,
         3,
         4
ORDER BY 1,
         3 DESC --7日内充值次数

SELECT t1.date, t1.distinct_id,
                t2.date, count(t2.distinct_id)AS "充值次数",
                         sum(t2.pay)AS "充值金额"
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
               pay
   FROM events
   WHERE event = 'pay'
     AND date BETWEEN '2020-07-20' AND '2020-08-02')t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t1.date,t2.date)<=7
AND datediff(t1.date,t2.date)>=0
GROUP BY 1,
         2,
         3
ORDER BY 1,
         4 DESC,5 DESC