SELECT t1.date,
       t1.distinct_id,
       sum(t1.pay)AS pay
FROM
  (SELECT date,distinct_id,
               pay
   FROM events
   WHERE event = 'pay'
     AND is_first_pay = 'yes'
     AND date BETWEEN '2020-08-17' AND '2020-08-30') t1
JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND date BETWEEN '2020-08-10' AND '2020-08-23')t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t1.date,t2.date)<=7
AND datediff(t1.date,t2.date)>=0
GROUP BY 1,
         2