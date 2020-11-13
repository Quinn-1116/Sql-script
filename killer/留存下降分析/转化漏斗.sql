SELECT t9.date,
       count(t9.distinct_id)AS `触发了实名认证的新用户数`,
       count(t4.distinct_id) AS `实名认证成功用户数`,
       count(t4.distinct_id)/count(t9.distinct_id) AS `实名认证成功转化率`,
       count(t5.distinct_id) AS `点击进房用户数`,
       count(t5.distinct_id)/count(t9.distinct_id) AS `新用户(触发实名认证)进房率`,
       count(t6.distinct_id) AS `分配房间用户数`,
       count(t6.distinct_id)/count(t9.distinct_id) AS `新用户(触发实名认证)匹配率`,
       count(t7.distinct_id) AS`开始游戏用户数`,
       count(t7.distinct_id)/count(t9.distinct_id) AS `新用户(触发实名认证)游戏率`,
       count(t8.distinct_id) AS`结束游戏用户数`,
       count(t8.distinct_id)/count(t9.distinct_id) AS `新用户(触发实名认证)完局率`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20014'
     AND regist_type IN ('celln',
                         'celln_direct')
     AND date BETWEEN current_date() - interval 14 DAY AND current_date()
   GROUP BY 1,
            2)t9
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'regRealName'
     AND appId = '20014'
     AND date BETWEEN current_date() - interval 14 DAY AND current_date()
     AND RESULT= 'success'
   GROUP BY 1,
            2)t4 ON t9.date = t4.date
AND t9.distinct_id = t4.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'cocosEvent'
     AND gameTypeId = 1800
     AND cocos_event = 'enter_room'
     AND date BETWEEN current_date() - interval 14 DAY AND current_date()
   GROUP BY 1,
            2)t5 ON t9.date = t5.date
AND t9.distinct_id = t5.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'roomAllocate'
     AND gameTypeId = 1800
     AND date BETWEEN current_date() - interval 14 DAY AND current_date()
   GROUP BY 1,
            2)t6 ON t9.date = t6.date
AND t9.distinct_id = t6.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date BETWEEN current_date() - interval 14 DAY AND current_date()
   GROUP BY 1,
            2)t7 ON t9.date = t7.date
AND t9.distinct_id = t7.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date BETWEEN current_date() - interval 14 DAY AND current_date()
   GROUP BY 1,
            2)t8 ON t9.date = t8.date
AND t9.distinct_id = t8.distinct_id
GROUP BY 1
ORDER BY 1