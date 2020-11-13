-- 哪些用户充值了？

SELECT sum(t2.amount)
FROM
  (SELECT distinct_id
   FROM events
   WHERE event = 'pay'
     AND date BETWEEN '2020-10-16' AND current_date()
     AND appId IN ('20014',
                   '30015')
   GROUP BY 1) t1
LEFT JOIN
  (SELECT distinct_id,
          sum(amount)AS amount
   FROM events
   WHERE event = 'addDiamond'
     AND amount >0
     AND date BETWEEN '2020-10-16' AND current_date()
   GROUP BY 1)t2 ON t1.distinct_id = t2.distinct_id

  --钻石的消耗去向
SELECT t2.reason_diamond, -sum(t2.amount) AS amount
FROM
  (SELECT distinct_id
   FROM events
   WHERE event = 'pay'
     AND date BETWEEN '2020-10-16' AND current_date()
     AND appId IN ('20014',
                   '30015')
   GROUP BY 1) t1
LEFT JOIN
  (SELECT distinct_id,
          reason_diamond,
          sum(amount)AS amount
   FROM events
   WHERE event = 'addDiamond'
     AND amount <0
     AND date BETWEEN '2020-10-16' AND current_date()
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
GROUP BY 1
ORDER BY 2 DESC