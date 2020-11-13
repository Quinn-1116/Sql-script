# coding: utf-8
import pandas as pd
import numpy as np
from ssql import ssql
import sys

# app DAU、DNU、DOU
df_app = ssql("""
SELECT t1.date,
       t1.app_dnu,
       t2.app_dau,
       (t2.app_dau-t1.app_dnu)AS app_dou
FROM
  (SELECT date,count(DISTINCT distinct_id)AS app_dnu--新用户

   FROM events
   WHERE event = 'register'
     AND appId IN ('20014',
                   '30015',
                   '20009')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1) t1
JOIN
  (SELECT date,count(DISTINCT distinct_id)AS app_dau--日活用户

   FROM events
   WHERE event = 'login'
     AND appId IN ('20014',
                   '30015',
                   '20009')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t2 ON t1.date = t2.date
""")

# 安卓单包DAU、DNU、DOU
df_android = ssql("""
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
""")

# ios单包DAU、DNU、DOU
df_ios = ssql("""
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
""")

# au单包DAU、DNU、DOU
df_au = ssql("""
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
""")

# 游戏的DAU、DNU、DOU
df_killer = ssql("""
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
""")


# 单包次留
df_app_r1 = ssql("""
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
   AND appId in('30015','20014','20009')
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
ORDER BY 1
""")

# ios单包次留
df_ios_r1 = ssql("""
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
     AND appId = '30015'
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
ORDER BY 1
""")

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
     AND appId = '20014'
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2)t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
ORDER BY 1
""")

# au单包次留
df_au_r1 = ssql("""
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
     AND appId = '20009'  
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


# 人均游戏局数
df_avg_game = ssql("""
SELECT sum(game_num)/count(distinct_id)as `人均游戏局数`
FROM
  (SELECT distinct_id,
          count(distinct_id)AS game_num
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t1""")


# 人均游戏时长
df_avg_duration = ssql("""
SELECT sum(duration)/count(distinct_id)as `人均游戏时长`
FROM
  (SELECT distinct_id,
          sum(duration/60000)AS duration
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date = current_date() - interval 1 DAY
   GROUP BY 1)t1""")


# 单局平均时长
df_game_avg_durantion = ssql("""SELECT sum(duration)/count(match_id)as `单局游戏平均时长`
FROM
  (SELECT match_id,
          (duration/60000) AS duration
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND date = current_date() - interval 1 DAY
   GROUP BY 1,
            2)t1""")

# 付费金额
df_pay_sum = ssql("""
SELECT appId,
       sum(pay) AS pay
FROM events
WHERE event = 'pay'
  AND appId IN ('20009',
                '20014',
                '30015')
  AND date = current_date() - interval 1 DAY
GROUP BY 1
""")

# 付费人数
df_pay_count = ssql("""
SELECT appId,
       count(distinct distinct_id) as `付费人数`
FROM events
WHERE event = 'pay'
  AND appId IN ('20009',
                '20014',
                '30015')
  AND date = current_date() - interval 1 DAY
GROUP BY 1
""")

# 安卓包游戏率
df_android_gameRate = ssql("""
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
     AND appId = '20014'
     AND date = current_date() - interval 1 day
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '20014'
     AND date = current_date() - interval 1 day
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date = current_date() - interval 1 day
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
GROUP BY 1
"""
)

# ios包游戏率
df_ios_gameRate = ssql("""
SELECT t1.date, count(t1.distinct_id) AS dnu,
                count(t2.distinct_id) AS login_dnu,
                count(t2.distinct_id)/count(t1.distinct_id) AS `注册-登录转化率`,
                count(t3.distinct_id) AS game_dnu,
                count(t3.distinct_id)/count(t1.distinct_id)AS `注册-游戏转化率`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId = '30015'
     AND date = current_date() - interval 1 day
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'login'
     AND appId = '30015'
     AND date = current_date() - interval 1 day
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date = current_date() - interval 1 day
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
GROUP BY 1
""")

df_gameRate = ssql("""
SELECT t1.date,
       count(t1.distinct_id) AS dnu,
       count(t3.distinct_id) AS game_dnu,
       count(t3.distinct_id)/count(t1.distinct_id)AS `注册-游戏转化率`
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND appId in('20014','30015') 
     AND date = current_date() - interval 1 day
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'gameStart'
     AND gameTypeId = 1800
     AND game_played = 0
     AND date = current_date() - interval 1 day
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.distinct_id = t3.distinct_id
GROUP BY 1
""")
def per_tf(x):
    return '%.2f%%' % (x * 100)


with open('每日数据播报.txt', 'w')as f:
    sys.stdout = f
    print("##" + df_app.loc[0,'date'] + "数据简报")
    print("=" * 20 + '\n' + "*敏感数据，请勿外传" + '\n' + "=" * 20)
    # print("**敏感数据，请勿外传")
    # print("=" * 20)
    print("游戏活跃用户数:" + str(df_killer.loc[0, 'game_dau']) + "\n"
          + "新增用户数:" + str(df_killer.loc[0, 'game_dnu']) + "\n"
          + "新增用户游戏率:" + str(per_tf(df_gameRate.loc[0, '注册-游戏转化率'])) + "\n"
          + "老用户数:" + str(df_killer.loc[0, 'game_dou']) + "\n"
          + "前一日新用户次留:" + str(per_tf(df_killer_r1.loc[0, 'game_new_user_r1'])) + "\n"
          + "人均局数:" + str(np.round(df_avg_game.loc[0, '人均游戏局数'], decimals=2)) + "\n"
          + "人均游戏时长:" + str(np.round(df_avg_duration.loc[0, '人均游戏时长'], decimals=2)) + "分钟" + "\n"
          + "单局平均时长:" + str(np.round(df_game_avg_durantion.loc[0, '单局游戏平均时长'], decimals=2)) + "分钟")
    print("=" * 20)
    print("app活跃用户数:" + str(df_app.loc[0, 'app_dau']) + "\n"
          + "新增用户数:" + str(df_app.loc[0, 'app_dnu']) + "\n"
          + "老用户数:" + str(df_app.loc[0, 'app_dou']) + "\n"
          + "付费用户数:" + str(df_pay_count['付费人数'].sum()) + "\n"
          + "付费总金额:" + str(df_pay_sum['pay'].sum()) + "\n"
          + "前一日新用户次留:" + str(per_tf(df_app_r1.loc[0, 'r1'])) + "\n"
          + "-" * 5 + "\n"
          + "安卓单包活跃用户数:" + str(df_android.loc[0, 'android_dau']) + "\n"
          + "新增用户数:" + str(df_android.loc[0, 'android_dnu']) + "\n"
          + "新增用户游戏率:" + str(per_tf(df_android_gameRate.loc[0, '注册-游戏转化率'])) + "\n"
          + "老用户数:" + str(df_android.loc[0, 'android_dou']) + "\n"
          + "付费用户数:" + str([df_pay_count[df_pay_count['appid'] == '20014'].reset_index(drop=True).loc[0,'付费人数'] if len(df_pay_count[df_pay_count['appid'] == '20014']) != 0 else "暂无"][0]) + "\n"
          + "付费总金额:" + str([df_pay_sum[df_pay_sum['appid'] == '20014'].reset_index(drop=True).loc[0,'pay'] if len(df_pay_sum[df_pay_sum['appid'] == '20014']) != 0 else "暂无"][0]) + "\n"
          + "前一日新用户次留:" + str(per_tf(df_android_r1.loc[0, 'android_r1'])) + "\n"
          + "-" * 5 + "\n"
          + "ios单包活跃用户数:" + str(df_ios.loc[0, 'ios_dau']) + "\n"
          + "新增用户数:" + str(df_ios.loc[0, 'ios_dnu']) + "\n"
          + "新增用户游戏率:" + str(per_tf(df_ios_gameRate.loc[0, '注册-游戏转化率'])) + "\n"
          + "老用户数:" + str(df_ios.loc[0, 'ios_dou']) + "\n"
          + "付费用户数:" + str([df_pay_count[df_pay_count['appid'] == '30015'].reset_index(drop=True).loc[0,'付费人数'] if len(df_pay_count[df_pay_count['appid'] == '30015']) != 0 else "暂无"][0]) + "\n"
          + "付费总金额:" + str([df_pay_sum[df_pay_sum['appid'] == '30015'].reset_index(drop=True).loc[0,'pay'] if len(df_pay_sum[df_pay_sum['appid'] == '30015']) != 0 else "暂无"][0]) + "\n"
          + "前一日新用户次留:" + str(per_tf(df_ios_r1.loc[0, 'ios_r1'])) + "\n"
          + "-" * 5 + "\n"
          + "au单包活跃用户数:" + str(df_au.loc[0, 'au_dau']) + "\n"
          + "新增用户数:" + str(df_au.loc[0, 'au_dnu']) + "\n"
          + "老用户数:" + str(df_au.loc[0, 'au_dou']) + "\n"
          + "付费用户数:" + str([df_pay_count[df_pay_count['appid'] == '20009'].reset_index(drop=True).loc[0,'付费人数'] if len(df_pay_count[df_pay_count['appid'] == '20009']) != 0 else "暂无"][0]) + "\n"
          + "付费总金额:" + str([df_pay_sum[df_pay_sum['appid'] == '20009'].reset_index(drop=True).loc[0,'pay'] if len(df_pay_sum[df_pay_sum['appid'] == '20009']) != 0 else "暂无"][0]) + "\n"
          + "前一日新用户次留:" + str(per_tf(df_au_r1.loc[0, 'au_r1']))
          )
    print("=" * 20)

from dingtalkchatbot.chatbot import DingtalkChatbot

# killer群
webhook = "https://oapi.dingtalk.com/robot/send?access_token=5c0ba0fd48989b39e6f696ddfe79f109fb04aabca6470658672175492457d525"
secret = "SEC53943bfd7039ee1990c42fa78d46b5701d63b5da0998a6fc16a0007e9ddeee9b"

# 测试群
# webhook = "https://oapi.dingtalk.com/robot/send?access_token=2606c23eaf70851235a10785081a8fedcc72d210c9379c9b960c32d571372b8a"
# secret = "SEC2fe3fce80cc0a5b2de41423c540b8f58c2f2c393a7c2ec28c75d9bdd0062939e"
xiaoding = DingtalkChatbot(webhook, secret=secret)

string = ''
f2 = open('每日数据播报.txt', "r")
lines = f2.readlines()
string = string.join(lines)
xiaoding.send_text(msg=string)
