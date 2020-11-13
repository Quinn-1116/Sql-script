SELECT t1.date,
       count(t1.distinct_id) AS `新增用户数`,
       count(t2.distinct_id) AS `登录用户数`,
       count(t2.distinct_id) /count(t1.distinct_id) AS `注册登录转化率`,
       count(t3.distinct_id) AS `触发实名认证用户数`,
       count(t3.distinct_id)/count(t1.distinct_id) AS `实名认证触发率`,
       count(t4.distinct_id) AS `实名认证成功用户数`,
       count(t4.distinct_id)/count(t3.distinct_id) AS `实名认证成功转化率`,
       count(t5.distinct_id) AS `点击进房用户数`,
       count(t5.distinct_id)/count(t3.distinct_id) AS `新用户(触发实名认证)进房率`,
       count(t6.distinct_id) AS `分配房间用户数`,
       count(t6.distinct_id)/count(t3.distinct_id) AS `新用户(触发实名认证)匹配率`,
       count(t7.distinct_id) AS`开始游戏用户数`,
       count(t7.distinct_id)/count(t3.distinct_id) AS `新用户(触发实名认证)游戏率`,
       count(t8.distinct_id) AS`结束游戏用户数`,
       count(t8.distinct_id)/count(t3.distinct_id) AS `新用户(触发实名认证)完局率`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'--注册

     AND regist_type NOT in('celln', 'celln_direct')
     AND appId = '30015'
     AND date BETWEEN '2020-10-23' AND current_date()
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'--登录

     AND appId = '30015'
     AND date BETWEEN '2020-10-23' AND current_date()
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'action'--防沉迷实名弹窗

     AND appId = '30015'
     AND date BETWEEN '2020-10-23' AND current_date()
     AND op_type = 'anti_indulgence_popup'
     AND pop_type = 'verified_mode_popup'
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
AND t2.distinct_id = t3.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'regRealName'--实名认证成功

     AND appId = '30015'
     AND date BETWEEN '2020-10-23' AND current_date()
     AND RESULT= 'success'
   GROUP BY 1,
            2)t4 ON t1.date = t4.date
AND t1.distinct_id = t4.distinct_id
AND t2.distinct_id = t4.distinct_id
AND t3.distinct_id = t4.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'cocosEvent'--进房

     AND gameTypeId = 1800
     AND cocos_event = 'enter_room'
     AND date BETWEEN '2020-10-23' AND current_date()
   GROUP BY 1,
            2)t5 ON t1.date = t5.date
AND t1.distinct_id= t5.distinct_id
AND t2.distinct_id = t5.distinct_id
AND t3.distinct_id = t5.distinct_id
AND t4.distinct_id = t5.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'roomAllocate'--进房

     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-23' AND current_date()
   GROUP BY 1,
            2)t6 ON t1.date = t6.date
AND t1.distinct_id= t6.distinct_id
AND t2.distinct_id= t6.distinct_id
AND t3.distinct_id = t6.distinct_id
AND t4.distinct_id = t6.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'--游戏开始

     AND gameTypeId = 1800
     AND game_played = 0
     AND date BETWEEN '2020-10-23' AND current_date()
   GROUP BY 1,
            2)t7 ON t1.date = t7.date
AND t1.distinct_id= t7.distinct_id
AND t2.distinct_id= t7.distinct_id
AND t3.distinct_id = t7.distinct_id
AND t4.distinct_id = t7.distinct_id
AND t6.distinct_id = t7.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameOver'--游戏结束

     AND gameTypeId = 1800
     AND date BETWEEN '2020-10-23' AND current_date()
   GROUP BY 1,
            2)t8 ON t1.date = t8.date
AND t1.distinct_id= t8.distinct_id
AND t2.distinct_id= t8.distinct_id
AND t3.distinct_id = t8.distinct_id
AND t4.distinct_id = t8.distinct_id
AND t6.distinct_id = t8.distinct_id
AND t7.distinct_id = t8.distinct_id
GROUP BY 1
ORDER BY 1