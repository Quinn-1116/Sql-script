SELECT t1.date,
       t2.reason_diamond,
       sum(t2.amount)AS amount
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'pay'
     AND is_first_pay = 'yes'
     AND date BETWEEN '2020-08-17' AND '2020-08-30') t1
LEFT JOIN
  (SELECT date,distinct_id,reason_diamond,-sum(amount)AS amount
   FROM events
   WHERE event = 'addDiamond'
     AND amount<0
     AND date BETWEEN '2020-08-17' AND '2020-08-30'
   GROUP BY 1,
            2,
            3)t2 ON t1.distinct_id = t2.distinct_id
AND t1.date = t2.date
GROUP BY 1,
         2
ORDER BY 1,
         3 DESC