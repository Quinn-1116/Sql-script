SELECT t1.date,
       t1.distinct_id,
       t2."游戏类型",
       count(t2.distinct_id)AS "转化前7日游戏局数"
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
  (SELECT date,distinct_id,
               CASE
                   WHEN gameTypeId = 100 THEN '说猜'
                   WHEN gameTypeId = 101 THEN '新画猜'
                   WHEN gameTypeId = 103 THEN '画意传情'
                   WHEN gameTypeId = 1001 THEN '怼球'
                   WHEN gameTypeId = 1004 THEN '狼人杀'
                   WHEN gameTypeId = 1100 THEN '阿瓦隆'
                   WHEN gameTypeId = 1150 THEN '卧底游戏'
                   WHEN gameTypeId = 1160 THEN '扫雷'
                   WHEN gameTypeId = 1161 THEN '麻将'
                   WHEN gameTypeId = 1171 THEN '剧本杀'
                   WHEN gameTypeId = 1180 THEN '撞击王者'
                   WHEN gameTypeId = 1190 THEN '乌诺'
                   WHEN gameTypeId = 1200 THEN '喷墨大师'
                   WHEN gameTypeId = 1201 THEN '别撞电杆'
                   WHEN gameTypeId = 1202 THEN '连连看'
                   WHEN gameTypeId = 1203 THEN '八分音符吼'
                   WHEN gameTypeId = 1206 THEN '五子棋'
                   WHEN gameTypeId = 1207 THEN '斗兽棋'
                   WHEN gameTypeId = 1208 THEN '消饼干'
                   WHEN gameTypeId = 1209 THEN '互怼学园'
                   WHEN gameTypeId = 1210 THEN '找你妹'
                   WHEN gameTypeId = 1212 THEN '别踩白块'
                   WHEN gameTypeId = 1213 THEN '找你妹2V2'
                   WHEN gameTypeId = 1214 THEN '一战到底2V2'
                   WHEN gameTypeId = 1215 THEN '一战到底'
                   WHEN gameTypeId = 1219 THEN '象棋'
                   WHEN gameTypeId = 1220 THEN '消星星'
                   WHEN gameTypeId = 1224 THEN '跳一跳'
                   WHEN gameTypeId = 1225 THEN '台球'
                   WHEN gameTypeId = 1226 THEN '台球2V2'
                   WHEN gameTypeId = 1300 THEN '画猜'
                   WHEN gameTypeId = 1600 THEN '精灵别跑'
               END AS "游戏类型"
   FROM events
   WHERE event = 'gameStart'
     AND date BETWEEN '2020-07-20' AND '2020-08-02')t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t1.date,t2.date)<=7
AND datediff(t1.date,t2.date)>=1
GROUP BY 1,
         2,
         3
ORDER BY 1,
         4 DESC