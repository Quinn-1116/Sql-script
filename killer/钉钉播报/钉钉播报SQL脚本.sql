------------------------------------------------------------------
单包的DAU、DNU、DOU
SELECT t1.date,
       t1.app_dnu,
       t2.app_dau,
       (t2.app_dau-t1.app_dnu)AS app_dou
FROM
  (SELECT date,count(DISTINCT distinct_id)AS app_dnu--新用户

   FROM events
   WHERE event = 'register'
     AND appId IN ('20014',
                   '30015'
                   '20009')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1) t1
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS app_dau--日活用户

   FROM events
   WHERE event = 'login'
     AND appId IN ('20014',
                   '30015'
                   '20009')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date
----------------------------------------------------------------
安卓单包的DAU、DNU、DOU
SELECT t1.date, t1.android_dnu,
                t2.android_dau,
                (t2.android_dau-t1.android_dnu)AS android_dou
FROM
  (SELECT date,count(DISTINCT distinct_id)AS android_dnu--新用户

   FROM events
   WHERE event = 'register'
     AND appId IN ('20014')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1) t1
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS android_dau--日活用户

   FROM events
   WHERE event = 'login'
     AND appId IN ('20014')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date
GROUP BY 1


ios单包的DAU、DNU、DOU
SELECT t1.date,t1.ios_dnu,
               t2.ios_dau,
               (t2.ios_dau-t1.ios_dnu)AS ios_dou
FROM
  (SELECT date,count(DISTINCT distinct_id)AS ios_dnu--新用户

   FROM events
   WHERE event = 'register'
     AND appId IN ('30015')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1) t1
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS ios_dau--日活用户

   FROM events
   WHERE event = 'login'
     AND appId IN ('30015')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date


au单包的DAU、DNU、DOU
  SELECT t1.date,t1.au_dnu,
               t2.au_dau,
               (t2.au_dau-t1.au_dnu)AS au_dou
FROM
  (SELECT date,count(DISTINCT distinct_id)AS au_dnu--新用户

   FROM events
   WHERE event = 'register'
     AND appId IN ('20009')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1) t1
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS au_dau--日活用户

   FROM events
   WHERE event = 'login'
     AND appId IN ('20009')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date
------------------------------------------------------------------
游戏的DAU、DNU、DOU
SELECT t1.date,
       t1.game_dnu,
       t2.game_dau,
       (t2.game_dau-t1.game_dnu)AS game_dou
FROM
  (SELECT date,count(DISTINCT distinct_id)AS game_dnu--新用户

   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date = current_date() - interval 1 DAY
   GROUP BY 1) t1
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS game_dau--日活用户

   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date
-------------------------------------------------------------------------

单包次留
SELECT t1.date,
       count(t1.distinct_id)AS register_num,
       count(t2.distinct_id)AS remain_num,
       count(t2.distinct_id)/count(t1.distinct_id) AS r1
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId in('30015','20014','20009') 
     AND date = current_date() - interval 2 DAY
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
ORDER BY 1



ios单包次留
SELECT t1.date,
       count(t1.distinct_id)AS register_num,
       count(t2.distinct_id)AS remain_num,
       count(t2.distinct_id)/count(t1.distinct_id) AS ios_r1
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '30015'
     AND date = current_date() - interval 2 DAY
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
ORDER BY 1


安卓单包次留
SELECT t1.date, count(t1.distinct_id)AS register_num,
                count(t2.distinct_id)AS remain_num,
                count(t2.distinct_id)/count(t1.distinct_id) AS android__r1
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20014'
     AND date = current_date() - interval 2 DAY
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
ORDER BY 1


au单包次留
SELECT t1.date,
       count(t1.distinct_id)AS register_num,
       count(t2.distinct_id)AS remain_num,
       count(t2.distinct_id)/count(t1.distinct_id) AS au_r1
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '20009'
     AND date = current_date() - interval 2 DAY
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
ORDER BY 1


游戏新用户次留
SELECT t1.date,
       count(t1.distinct_id) AS game_new_user,
       count(t2.distinct_id) AS game,
       count(t2.distinct_id)/count(t1.distinct_id) game_new_user_r1
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date = current_date() - interval 2 DAY
   GROUP BY 1,
            2) t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
-------------------------------------------------------------------------------------------
付费金额
SELECT appId,
       sum(pay) AS pay
FROM events
WHERE event = 'pay'
  AND appId IN ('20009',
                '20014',
                '30015')
  AND date = current_date() - interval 1 DAY
GROUP BY 1

付费人数
SELECT appId,
       count(distinct distinct_id) as `付费人数`
FROM events
WHERE event = 'pay'
  AND appId IN ('20009',
                '20014',
                '30015')
  AND date = current_date() - interval 1 DAY
GROUP BY 1
-------------------------------------------------------------------------------------------
人均游戏时长
SELECT sum(duration)/count(distinct_id)as `人均游戏时长`
FROM
  (SELECT distinct_id,
          sum(duration/60000)AS duration
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t1


人均游戏局数
SELECT sum(game_num)/count(distinct_id)as `人均游戏局数`
FROM
  (SELECT distinct_id,
          count(distinct_id)AS game_num
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t1


单局游戏平均时长
SELECT sum(duration)/count(match_id)as `单局游戏平均时长`
FROM
  (SELECT match_id,
          (duration/60000) AS duration
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2)t1




游戏的DAU、DNU、DOU
SELECT t1.date,
       t1.game_dnu,
       t2.game_dau,
       (t2.game_dau-t1.game_dnu)AS game_dou
FROM
  (SELECT date,count(DISTINCT distinct_id)AS game_dnu--新用户

   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date = current_date() - interval 1 DAY
   GROUP BY 1) t1
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS game_dau--日活用户用户

   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date


 app的DAU、DNU、DOU
SELECT t1.date,
       t1.app_dnu,
       t2.app_dau,
       (t2.app_dau-t1.app_dnu)AS app_dou
FROM
  (SELECT date,count(DISTINCT distinct_id)AS app_dnu--新用户

   FROM events
   WHERE event = 'register'
     AND appId IN ('20014',
                   '30015')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1) t1
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS app_dau--日活用户

   FROM events
   WHERE event = 'login'
     AND appId IN ('20014',
                   '30015')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date


  
SELECT t1.date, t1.android_dnu,
                t2.android_dau,
                (t2.android_dau-t1.android_dnu)AS android_dou
FROM
  (SELECT date,count(DISTINCT distinct_id)AS android_dnu--新用户

   FROM events
   WHERE event = 'register'
     AND appId IN ('20014')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1) t1
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS android_dau--日活用户

   FROM events
   WHERE event = 'login'
     AND appId IN ('20014')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date



SELECT t1.date,t1.ios_dnu,
               t2.ios_dau,
               (t2.ios_dau-t1.ios_dnu)AS ios_dou
FROM
  (SELECT date,count(DISTINCT distinct_id)AS ios_dnu--新用户

   FROM events
   WHERE event = 'register'
     AND appId IN ('30015')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1) t1
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS ios_dau--日活用户

   FROM events
   WHERE event = 'login'
     AND appId IN ('30015')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date