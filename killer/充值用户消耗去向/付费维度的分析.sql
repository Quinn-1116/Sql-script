SELECT is_first_pay,
       count(DISTINCT distinct_id),
       sum(pay)AS pay
FROM events
WHERE event = 'pay'
  AND date BETWEEN '2020-10-16' AND current_date()
  AND appId IN ('20014',
                '30015')
GROUP BY 1
SELECT distinct_id,
       count(distinct_id)
FROM events
WHERE event = 'pay'
  AND date BETWEEN '2020-10-16' AND current_date()
  AND appId IN ('20014',
                '30015')
GROUP BY 1
ORDER BY 2 DESC


SELECT t1.distinct_id,
       datediff(now(), t2."注册时间") as "注册距今天数",
       t2.reg_gender
FROM
  (SELECT distinct_id
   FROM events
   WHERE event = 'pay'
     AND date BETWEEN '2020-10-16' AND current_date()
     AND appId IN ('20014',
                   '30015')
   GROUP BY 1)t1
JOIN
  (SELECT second_id,
          FROM_UNIXTIME(CAST($signup_time/1000 AS BIGINT))AS "注册时间",
          reg_gender
   FROM users
   WHERE second_id IS NOT NULL)t2 ON t1.distinct_id = t2.second_id