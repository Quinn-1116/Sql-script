
SELECT t0.date,
       CASE
           WHEN t0."首充距注册时长">=0
                AND t0."首充距注册时长"<=7 THEN '7日内完成首充'
           WHEN t0."首充距注册时长">7
                AND t0."首充距注册时长"<=14 THEN '7-14内完成首充'
           WHEN t0."首充距注册时长">14
                AND t0."首充距注册时长"<=30 THEN '14-30内完成首充'
           WHEN t0."首充距注册时长">30
                AND t0."首充距注册时长"<=60 THEN '30-60内完成首充'
           WHEN t0."首充距注册时长">60
                AND t0."首充距注册时长"<=90 THEN '60-90内完成首充'
           WHEN t0."首充距注册时长">90
                AND t0."首充距注册时长"<=180 THEN '90-180内完成首充'
           WHEN t0."首充距注册时长">180 THEN '首充时间距注册超过半年'
       END AS "首充距注册时长分布",
       sum(t0.amount)AS amount
FROM
  (SELECT t1.date,
          datediff(t1.date,t2."注册时间")AS "首充距注册时长",
          count(t1.distinct_id)AS amount
   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'pay'
        AND is_first_pay = 'yes'
        AND date BETWEEN '2020-08-17' AND '2020-08-30') t1
   LEFT  JOIN
     (SELECT second_id,
             FROM_UNIXTIME(CAST($signup_time/1000 AS BIGINT))AS "注册时间"
      FROM users
      WHERE second_id IS NOT NULL) t2 ON t1.distinct_id = t2.second_id
   GROUP BY 1,
            2
   ORDER BY 1)t0
WHERE t0."首充距注册时长" IS NOT NULL
GROUP BY 1,
         2
ORDER BY 1