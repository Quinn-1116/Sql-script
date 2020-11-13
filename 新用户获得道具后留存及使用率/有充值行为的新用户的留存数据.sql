SELECT t3.date,
       count(t3.distinct_id)AS "当日付费的新注册用户",
       count(t4.distinct_id)AS "次日留存用户数"
FROM
  (SELECT t2.date,
          t2.distinct_id
   FROM
     (SELECT date,distinct_id,
                  pay
      FROM events
      WHERE event = 'pay'
        AND date BETWEEN '2020-08-01' AND '2020-08-30') t1
   JOIN
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'register'
        AND date BETWEEN '2020-08-01' AND '2020-08-30')t2 ON t1.distinct_id = t2.distinct_id
   AND t1.date = t2.date
   GROUP BY 1,
            2) t3
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND date BETWEEN '2020-08-02' AND '2020-08-30'
   GROUP BY 1,
            2)t4 ON t3.distinct_id = t4.distinct_id
AND datediff(t4.date,t3.date) = 1
GROUP BY 1
ORDER BY 1


--付费新用户的7日留存
SELECT t3.date,
       count(t3.distinct_id)AS "当日付费的新注册用户",
       count(t4.distinct_id)AS "7日留存用户数"
FROM
  (SELECT t2.date,
          t2.distinct_id
   FROM
     (SELECT date,distinct_id,
                  pay
      FROM events
      WHERE event = 'pay'
        AND date BETWEEN '2020-08-01' AND '2020-08-30') t1
   JOIN
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'register'
        AND date BETWEEN '2020-08-01' AND '2020-08-30')t2 ON t1.distinct_id = t2.distinct_id
   AND t1.date = t2.date
   GROUP BY 1,
            2) t3
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND date BETWEEN '2020-08-02' AND '2020-08-30'
   GROUP BY 1,
            2)t4 ON t3.distinct_id = t4.distinct_id
AND datediff(t4.date,t3.date) = 7
GROUP BY 1
ORDER BY 1


--未付费用户的7日留存
SELECT t3.date,
       count(t3.distinct_id)AS "当日未付费的新注册用户",
       count(t4.distinct_id)AS "7日留存用户数"
FROM
  (SELECT t2.date,
          t2.distinct_id
   FROM
     (SELECT date,distinct_id,
                  pay
      FROM events
      WHERE event = 'pay'
        AND date BETWEEN '2020-08-01' AND '2020-08-30') t1
   RIGHT JOIN
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'register'
        AND date BETWEEN '2020-08-01' AND '2020-08-30')t2 ON t1.distinct_id = t2.distinct_id
   AND t1.date = t2.date
   WHERE t1.distinct_id IS NULL)t3
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND date BETWEEN '2020-08-02' AND '2020-08-30'
   GROUP BY 1,
            2)t4 ON t3.distinct_id = t4.distinct_id
AND datediff(t4.date,t3.date) = 7
GROUP BY 1
ORDER BY 1



