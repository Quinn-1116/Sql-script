确认一下玩过太空杀游戏和没有玩过太空杀游戏用户在单包的次留趋势，确认下游戏率下降对留存下降的影响；
--游戏转化率
SELECT t1.date,
       count(t1.distinct_id) AS dnu,
       count(t2.distinct_id) AS login_dnu,
       count(t2.distinct_id)/count(t1.distinct_id) AS `注册-登录转化率`,
       count(t3.distinct_id) AS game_dnu,
       count(t3.distinct_id)/count(t1.distinct_id)AS `注册-游戏转化率`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20009'
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20009'
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
GROUP BY 1
ORDER BY 1



--新注册用户的app次留
SELECT t1.date,
       count(t1.distinct_id)AS `app_dnu`,
       count(t2.distinct_id)AS `retention`,
       count(t2.distinct_id)/count(t1.distinct_id)AS `r_1`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20009'
     AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20009'
     AND date BETWEEN '2020-10-21' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date)= 1
GROUP BY 1
ORDER BY 1




--玩了游戏的新注册用户的app次留
SELECT t2.date,
       count(t2.distinct_id) AS `game_amount`,
       count(t4.distinct_id) AS `game_r1`,
       count(t4.distinct_id) /count(t2.distinct_id) as `game_r1_rate`
FROM
  (SELECT t1.date,
          t1.distinct_id
   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'register'
        AND appId = '20009'
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t1
   LEFT JOIN
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND game_played = 0
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t3 ON t1.date = t3.date
   AND t1.distinct_id = t3.distinct_id
   WHERE t3.distinct_id IS NOT NULL
   GROUP BY 1,
            2) t2
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20009'
     AND date BETWEEN '2020-10-21' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t4 ON t2.distinct_id = t4.distinct_id
AND datediff(t4.date,t2.date) = 1
GROUP BY 1
ORDER BY 1



--没有玩游戏的新注册用户的app次留
SELECT t2.date,
       count(t2.distinct_id) AS `not_game_amount`,
       count(t4.distinct_id) AS `not_game_r1`,
       count(t4.distinct_id) /count(t2.distinct_id) as `not_game_r1_rate`
FROM
  (SELECT t1.date,--没有玩游戏的新用户
          t1.distinct_id
   FROM
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'register'
        AND appId = '20009'
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t1
   LEFT JOIN
     (SELECT date,distinct_id
      FROM events
      WHERE event = 'gameStart'
        AND gameTypeId = 1800
        AND game_played = 0
        AND date BETWEEN '2020-10-20' AND current_date() - interval 1 DAY
      GROUP BY 1,
               2)t3 ON t1.date = t3.date
   AND t1.distinct_id = t3.distinct_id
   WHERE t3.distinct_id IS NULL
   GROUP BY 1,
            2) t2
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20009'
     AND date BETWEEN '2020-10-21' AND current_date() - interval 1 DAY
   GROUP BY 1,
            2)t4 ON t2.distinct_id = t4.distinct_id
AND datediff(t4.date,t2.date) = 1
GROUP BY 1
ORDER BY 1





--实验组的游戏率
SELECT t1.date,
       count(t1.distinct_id) AS dnu,
       count(t2.distinct_id) AS login_dnu,
       count(t2.distinct_id)/count(t1.distinct_id) AS `注册-登录转化率`,
       count(t3.distinct_id) AS game_dnu,
       count(t3.distinct_id)/count(t1.distinct_id)AS `注册-游戏转化率`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20009'
     AND STRRIGHT(distinct_id,2) BETWEEN '00' AND '49'
     and time >='2020-11-04 15:00:00'
     AND date between '2020-11-04' and  current_date()
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20009'
     AND STRRIGHT(distinct_id,2) BETWEEN '00' AND '49'
     and time >='2020-11-04 15:00:00'
     AND date between '2020-11-04' and  current_date()
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND STRRIGHT(distinct_id,2) BETWEEN '00' AND '49'
     and time >='2020-11-04 15:00:00'
    AND date between '2020-11-04' and  current_date()
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
GROUP BY 1
ORDER BY 1



--对照组的游戏率
SELECT t1.date,
       count(t1.distinct_id) AS dnu,
       count(t2.distinct_id) AS login_dnu,
       count(t2.distinct_id)/count(t1.distinct_id) AS `注册-登录转化率`,
       count(t3.distinct_id) AS game_dnu,
       count(t3.distinct_id)/count(t1.distinct_id)AS `注册-游戏转化率`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20009'
     AND STRRIGHT(distinct_id,2) BETWEEN '50' AND '99'
     and time >='2020-11-04 15:00:00'
     AND date between '2020-11-04' and  current_date()
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20009'
      AND STRRIGHT(distinct_id,2) BETWEEN '50' AND '99'
     and time >='2020-11-04 15:00:00'
     AND date between '2020-11-04' and  current_date()
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND STRRIGHT(distinct_id,2) BETWEEN '50' AND '99'
     and time >='2020-11-04 15:00:00'
    AND date between '2020-11-04' and  current_date()
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
GROUP BY 1
ORDER BY 1