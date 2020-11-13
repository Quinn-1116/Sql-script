-- 在没有游戏的新注册用户中，有多少用户触发了实名认证策略，且没有进行实名认证

SELECT t20.date,
       count(t20.distinct_id)AS `未游戏用户数`,
       count(t10.distinct_id)AS `未游戏用户中未提交实名认证的用户数`
FROM
  (SELECT t1.date,
          --触发了实名认证但是没有提交实名认证的用户数

          t1.distinct_id
   FROM
     (SELECT date, regist_type,
                   distinct_id
      FROM events
      WHERE event = 'register'
        AND appId in('20014','30015')
        AND date BETWEEN '2020-10-20' AND current_date()
      GROUP BY 1,
               2,
               3)t1
   JOIN
     (SELECT date, distinct_id
      FROM events
      WHERE event = 'action'
        AND appId in('20014','30015')
        AND op_type = 'anti_indulgence_popup'
        AND pop_type in('close_service_popup','verified_mode_popup')
        AND gameTypeId = 1800
        AND date BETWEEN '2020-10-20' AND current_date()
      GROUP BY 1,
               2)t2 ON t1.distinct_id = t2.distinct_id
   LEFT JOIN
     (SELECT date, distinct_id
      FROM events
      WHERE event = 'regRealName'
        AND appId IN ('20014',
                      '30015')
        AND RESULT = 'success'
        AND date BETWEEN '2020-10-20' AND current_date()
      GROUP BY 1,
               2)t3 ON t2.distinct_id = t3.distinct_id
   AND t1.distinct_id = t3.distinct_id
   WHERE t3.distinct_id IS NULL
   GROUP BY 1 ,
            2)t10
RIGHT JOIN
  (SELECT t1.date,t1.distinct_id
   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'register'
        AND appId IN ('20014',
                      '30015')
        AND date BETWEEN '2020-10-20' AND current_date()
      GROUP BY 1,
               2)t1
   LEFT JOIN
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND game_played = 0
        AND date BETWEEN '2020-10-20' AND current_date()
      GROUP BY 1,
               2)t3 ON t1.distinct_id = t3.distinct_id
   AND t1.date = t3.date
   WHERE t3.distinct_id IS NULL
   GROUP BY 1,
            2) t20 ON t10.distinct_id = t20.distinct_id
AND t10.date = t20.date
GROUP BY 1
ORDER BY 1