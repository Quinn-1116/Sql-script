-- B版本：单游戏渠道: 小米、OPPO的游戏率
SELECT t1.date,
       count(t1.distinct_id) AS app_dnu,
       count(t2.distinct_id) AS first_game_num,
       count(t2.distinct_id)/count(t1.distinct_id)AS game_ration
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20014'
     AND date BETWEEN '2020-10-19' AND CURRENT_DATE()
     AND channelId IN ('114',
                       '130')
   GROUP BY 1,
            2) t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-19' AND CURRENT_DATE()
     AND game_played = 0
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND t1.date = t2.date
GROUP BY 1
ORDER BY 1

-- A版本：玩吧形态的游戏率。 渠道: VIVO、华为、应用宝、百度、魅族、360手助、联想、豌豆荚
SELECT t1.date,
       count(t1.distinct_id) AS app_dnu,
       count(t2.distinct_id) AS first_game_num,
       count(t2.distinct_id)/count(t1.distinct_id)AS game_ration
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20014'
     AND date BETWEEN '2020-10-19' AND CURRENT_DATE()
     AND channelId IN ('131','122','113','111','127','112','125','116')
     -- A版本：玩吧形态. 渠道: VIVO、华为、应用宝、百度、魅族、360手助、联想、豌豆荚
   GROUP BY 1,
            2) t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-19' AND CURRENT_DATE()
     AND game_played = 0
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND t1.date = t2.date
GROUP BY 1
ORDER BY 1



--单游戏形态的游戏局数
SELECT t2.date,
       t2.distinct_id,
       t2.game_num
FROM
  (SELECT second_id
   FROM users
   WHERE reg_channelId IN ('114',
                           '130')
   GROUP BY 1) t1
JOIN
  (SELECT date, distinct_id,
                count(distinct_id)AS game_num
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-19' AND CURRENT_DATE()
   GROUP BY 1,
            2)t2 ON t1.second_id = t2.distinct_id 


--玩吧形态的游戏局数
SELECT t2.date, t2.distinct_id,
                t2.game_num
FROM
  (SELECT second_id
   FROM users
   WHERE reg_channelId IN ('131',
                           '122',
                           '113',
                           '111',
                           '127',
                           '112',
                           '125',
                           '116')
   GROUP BY 1) t1
JOIN
  (SELECT date, distinct_id,
                count(distinct_id)AS game_num
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-19' AND CURRENT_DATE()
   GROUP BY 1,
            2)t2 ON t1.second_id = t2.distinct_id


