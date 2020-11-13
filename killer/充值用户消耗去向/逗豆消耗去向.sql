SELECT t2.reason,
       sum(t2.amount)AS amount
FROM
  (SELECT distinct_id
   FROM events
   WHERE event = 'pay'
     AND date BETWEEN '2020-10-16' AND current_date()
     AND appId IN ('20014',
                   '30015')
   GROUP BY 1)t1
LEFT JOIN
  (SELECT distinct_id,reason,-sum(amount)AS amount
   FROM events
   WHERE event = 'addItem'
     AND item_id = 1
     AND amount<0
     -- AND reason NOT LIKE '%vice%'
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
GROUP BY 1
ORDER BY 2 DESC