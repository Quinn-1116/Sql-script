import pandas as pd
from ssql import ssql

# app日活
df_app_dau = ssql("""SELECT date,count(DISTINCT distinct_id)as `单包_DAU`
FROM events
WHERE event = 'login'
  AND appId IN ('20014',
                '30015')
  AND date = current_date() - interval 1 DAY
GROUP BY 1""")

# 安卓单包日活
df_android_dau = ssql("""SELECT date,count(DISTINCT distinct_id)as `安卓_DAU`
FROM events
WHERE event = 'login'
  AND appId = '20014'
  AND date = current_date() - interval 1 DAY
  group by 1""")

# ios单包日活
df_ios_dau = ssql("""SELECT date,count(DISTINCT distinct_id)as `ios_DAU`
FROM events
WHERE event = 'login'
  AND appId = '30015'
  AND date = current_date() - interval 1 DAY
  group by 1""")

# 游戏的DAU
df_killer_dau = ssql("""SELECT date,count(DISTINCT distinct_id) as killer_dau
FROM events
WHERE event = 'gameStart'
  AND gameTypeId = 1800
  AND date = current_date() - interval 1 DAY
GROUP BY 1""")

# app新增用户数
df_app_dnu = ssql("""SELECT date,count(DISTINCT distinct_id)AS `单包_DNU`
FROM events
WHERE event = 'register'
  AND appId in('20014','30015')
  AND date = current_date() - interval 1 DAY
GROUP BY 1""")

# app新增用户数（安卓）
df_android_dnu = ssql("""SELECT date,count(DISTINCT distinct_id)as `安卓_DNU`
FROM events
WHERE event = 'register'
  AND appId = '20014'
  AND date = current_date() - interval 1 DAY
  group by 1
""")

# app新增用户数（ios）
df_ios_dnu = ssql("""SELECT date,count(DISTINCT distinct_id)as `ios_DNU`
FROM events
WHERE event = 'register'
  AND appId = '30015'
  AND date = current_date() - interval 1 DAY
  group by 1""")

# 游戏新增用户数
df_killer_dnu = ssql("""SELECT date,count(DISTINCT distinct_id)AS `游戏DNU`
FROM events
WHERE event = 'gameStart'
  AND gameTypeId = 1800
  AND game_played = 0
  AND date = current_date() - interval 1 DAY
GROUP BY 1""")


# 单包次留
df_app_r1 = ssql("""SELECT t1.date,
       count(t1.distinct_id)AS register_num,
       count(t2.distinct_id)AS remain_num,
       count(t2.distinct_id)/count(t1.distinct_id) AS r1
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId in('30015','20014') 
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
ORDER BY 1""")

# ios单包次留
df_ios_r1 = ssql("""SELECT t1.date,
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
ORDER BY 1""")

# 安卓单包次留
df_android_r1 = ssql("""SELECT t1.date, count(t1.distinct_id)AS register_num,
                count(t2.distinct_id)AS remain_num,
                count(t2.distinct_id)/count(t1.distinct_id) AS android_r1
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
""")

# 游戏新用户次留
df_killer_r1 = ssql("""SELECT t1.date,
       count(t1.distinct_id) AS game_new_user,
       count(t2.distinct_id) AS game_old_user,
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
GROUP BY 1""")

print(df_app_r1)
# print(df_killer_dnu.dtypes)