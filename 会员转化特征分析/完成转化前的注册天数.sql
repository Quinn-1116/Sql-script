 --注册时间分布

SELECT t1.date,
       t1.distinct_id,
       t2."注册距今天数"
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
  (SELECT second_id,
          FROM_UNIXTIME(CAST($signup_time/1000 AS BIGINT))AS "注册时间",
          FROM_UNIXTIME(CAST(last_logintime/1000 AS BIGINT))AS "上次登录时间",
          datediff(now() ,FROM_UNIXTIME(CAST($signup_time/1000 AS BIGINT))) AS "注册距今天数",
          datediff(now() ,FROM_UNIXTIME(CAST(last_logintime/1000 AS BIGINT)))AS "最近一次登录距今天数"
   FROM users
   WHERE second_id IS NOT NULL)t2 ON t1.distinct_id = t2.second_id
GROUP BY 1,
         2,
         3
ORDER BY t1.date