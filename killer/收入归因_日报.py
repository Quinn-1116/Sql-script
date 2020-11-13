#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
from ssql import ssql
from matplotlib import pyplot as plt
# from colorama import Fore
from datetime import datetime
import datetime
import calendar
import warnings
import sys
import math


# In[2]:


# 1. 相关函数准备
# 1.1 日期星期转换
# 0-周一 6-周日
def check_weekday(str1):
    date = str1.split("-")
    year, month, day = int(date[0]), int(date[1]), int(date[2])
    weekday = calendar.weekday(year, month, day)
    return weekday


# 1.2 matplotlib中文字体
plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False


# 1.3 输入按时间顺序排列的df[列名] 得到两日差值及变化率
def gap(list):
    return np.round((list - list.shift(1)).astype(float), 2)


def change(list):
    return np.round((gap(list) / list.shift(1) * 100).astype(float), 0)


# 2. 数据准备
# 2.1 近14日收入
df_pay = ssql('''select date,sum(pay)/10000 pay from events 
where event = 'pay'
and (is_sandbox = 0 or is_sandbox is null)
and date between current_date() - interval 2 day  and current_date() - interval 1 day
group by 1 order by 1''')

# 2.2 DAU
df_dau = ssql('''SELECT date, count(distinct distinct_id) dau
from events
where event = 'login'
and date between current_date() - interval 2 day  and current_date() - interval 1 day
group by 1
order by 1''')

# 2.3 每日付费用户数
df_pay_user = ssql('''SELECT date, count(distinct distinct_id) pay_users, sum(pay)/count(distinct distinct_id) arppu
from events
where event = 'pay'
and date between current_date() - interval 2 day  and current_date() - interval 1 day
group by 1
order by 1''')


# 2.4 大R、超R人数
def big_r(date):
    big_r_ = ssql('''SELECT count(distinct distinct_id) AS big_r
    FROM( SELECT distinct_id
          from events
          where date between '{date}' - interval '29' day and '{date}'
          and event = 'pay'
          group by 1
          having sum(pay) >= 10000
          and sum(pay) < 25000)T'''.format(date=date))
    return big_r_


def super_r(date):
    super_r_ = ssql('''SELECT count(distinct distinct_id) AS super_r
    FROM( SELECT distinct_id
          from events
          where date between '{date}' - interval '29' day and '{date}'
          and event = 'pay'
          group by 1
          having sum(pay) >= 25000)T'''.format(date=date))
    return super_r_


df_big_r = pd.DataFrame()
df_super_r = pd.DataFrame()

date = df_pay['date'][1]
delta = datetime.timedelta(days=1)

for i in pd.date_range((datetime.datetime.strptime(date, '%Y-%m-%d') - delta).strftime('%Y-%m-%d'), date):
    # print(i)
    df_big_r = df_big_r.append(big_r(i))
    df_super_r = df_super_r.append(super_r(i))
df_big_super_r = pd.concat([df_big_r, df_super_r], axis=1)


# 2.5 大R超R付费人数及金额
def pay_big_r(date):
    pay_big_r_ = ssql('''SELECT count(distinct T2.distinct_id) AS pay_big_r, sum(total_pay)/10000 AS total_pay_big_r
                  FROM(
                  SELECT distinct_id
                  from events
                  where date between '{date}' - interval '29' day and '{date}'
                  and event = 'pay'
                  group by 1
                  having sum(pay) >= 10000
                  and sum(pay) < 25000)T1
                  JOIN(
                  select distinct distinct_id 
                  from events
                  where date = '{date}'
                  and event = 'login')T
                  ON T1.distinct_id = T.distinct_id
                  JOIN(
                  select distinct_id, sum(pay) AS total_pay
                  from events
                  where date = '{date}'
                  and event = 'pay'
                  group by 1)T2
                  ON T1.distinct_id = T2.distinct_id'''.format(date=date))
    return pay_big_r_


def pay_super_r(date):
    pay_super_r_ = ssql('''SELECT count(distinct T2.distinct_id) AS pay_super_r, sum(total_pay)/10000 AS total_pay_super_r
                      FROM(
                      SELECT distinct_id
                      from events
                      where date between '{date}' - interval '29' day and '{date}'
                      and event = 'pay'
                      group by 1
                      having sum(pay) >= 25000)T1
                      JOIN(
                      select distinct distinct_id 
                      from events
                      where date = '{date}'
                      and event = 'login')T
                      ON T1.distinct_id = T.distinct_id
                      JOIN(
                      select distinct_id, sum(pay) AS total_pay
                      from events
                      where date = '{date}'
                      and event = 'pay'
                      group by 1)T2
                      ON T1.distinct_id = T2.distinct_id'''.format(date=date))
    return pay_super_r_


df_pay_big_r = pd.DataFrame()
df_pay_super_r = pd.DataFrame()

for i in pd.date_range((datetime.datetime.strptime(date, '%Y-%m-%d') - delta).strftime('%Y-%m-%d'), date):
    # print(i)
    df_pay_big_r = df_pay_big_r.append(pay_big_r(i))
    df_pay_super_r = df_pay_super_r.append(pay_super_r(i))

df_pay_big_super_r = pd.concat([df_pay_big_r, df_pay_super_r], axis=1)

# 2.6 钻石消耗细分
df_diamond = ssql('''select date,
case when reason_diamond = 'buy_gamecoin' then 'doudou'
    when reason_diamond = 'buy_gift' then 'gift'
    when reason_diamond = 'buy_gift_coupon' then 'gift_coupon'
    when reason_diamond like 'pet_energy_map%' then 'battlepass'
else '其他' end reason_diamond,-round(sum(amount)/100000,2) amount fro m events 
where event = 'addDiamond'
and amount < 0
and date between current_date() - interval 2 day and current_date() - interval 1 day 
group by 1,2 order by 1''')

df_diamond_pivot = df_diamond.pivot_table(index='date', columns='reason_diamond')
df_diamond_pivot.columns = df_diamond_pivot.columns.droplevel()

df_all = pd.concat([df_pay, df_dau, df_pay_user, df_big_super_r.reset_index(),
                    df_pay_big_super_r.reset_index(), df_diamond_pivot.reset_index()], axis=1).drop(['index'], axis=1)
df_all['arpu'] = df_all['pay'] / df_all['dau'] * 10000
# 删除重复列
df_all = df_all.T.drop_duplicates().T.fillna(0)

# 2.7
# 逗豆消耗 逗豆单位：百万doudou
df_doudou = ssql('''
SELECT date, CASE WHEN reason LIKE 'fish%' THEN 'fish'
                          WHEN reason LIKE 'mahjong_%' THEN 'mahjong'
                          WHEN reason LIKE 'bet_guess_%' then 'bet_guess'
                          WHEN reason LIKE 'melee_balance_%' then 'melee' 
                  end as reason,-round(sum(amount)/1000000,2) amount
from events
where event = 'addItem'
and item_id = 1
and date between current_date() - interval 2 day  and current_date() - interval 1 day
group by 1,2
having 2 is not null
order by 3''')

df_doudou_pivot = df_doudou.pivot_table(index='date', columns='reason').fillna(0)  # .to_clipboard()
df_doudou_pivot.columns = df_doudou_pivot.columns.droplevel()
df_doudou_pivot['doudou'] = df_doudou_pivot.sum(axis=1)

# 2.8 运营活动及收入
df_activity = ssql('''select date, reason_diamond, -round(sum(amount)/100000,2) amount 
from events 
where event = 'addDiamond'
and reason_diamond like 'activity_%'
and amount < 0
and date between current_date() - interval 2 day  and current_date() - interval 1 day
group by 1,2
order by 1''')

df_activity_pivot = df_activity.pivot_table(index='date', columns='reason_diamond').fillna(0).fillna(
    0)  # .to_clipboard()
df_activity_pivot.columns = df_activity_pivot.columns.droplevel()


# 2.9 大R、超R钻石消费场景 - 用于除逗豆
def big_r_situation(date):
    big_r_situation_ = ssql('''select t1.date, 
    case when reason_diamond = 'buy_gamecoin' then 'doudou'
    when reason_diamond = 'buy_gift' then 'gift'
    when reason_diamond = 'buy_gift_coupon' then 'gift_coupon'
    when reason_diamond like 'pet_energy_map%' then 'battlepass'
    else '其他' end reason_diamond,-round(sum(amount)/100000,2) amount 
    from 
    (select date, reason_diamond, distinct_id, amount
    from events 
    where event = 'addDiamond'
    and amount < 0
    and date ='{date}') t1
    join 
    (select distinct_id
    from events
    where event = 'pay'
    and date between '{date}'- interval '29' day and '{date}'
    group by 1
    having sum(pay) >= 10000 
    and sum(pay) < 25000)t2
    on t1.distinct_id = t2.distinct_id
    group by 1,2 order by 1'''.format(date=date))
    df_big_situation_pivot = big_r_situation_.pivot_table(index='date', columns='reason_diamond')
    df_big_situation_pivot.columns = df_big_situation_pivot.columns.droplevel()
    return df_big_situation_pivot


def super_r_situation(date):
    super_r_situation_ = ssql('''select t1.date, 
    case when reason_diamond = 'buy_gamecoin' then 'doudou'
    when reason_diamond = 'buy_gift' then 'gift'
    when reason_diamond = 'buy_gift_coupon' then 'gift_coupon'
    when reason_diamond like 'pet_energy_map%' then 'battlepass'
    else '其他' end reason_diamond,-round(sum(amount)/100000,2) amount 
    from 
    (select date, reason_diamond, distinct_id, amount
    from events 
    where event = 'addDiamond'
    and amount < 0
    and date ='{date}') t1
    join 
    (select distinct_id
    from events
    where event = 'pay'
    and date between '{date}'- interval '29' day and '{date}'
    group by 1
    having sum(pay) >= 25000)t2
    on t1.distinct_id = t2.distinct_id
    group by 1,2 order by 1'''.format(date=date))
    df_super_situation_pivot = super_r_situation_.pivot_table(index='date', columns='reason_diamond').fillna(
        0)  # .to_clipboard()
    df_super_situation_pivot.columns = df_super_situation_pivot.columns.droplevel()
    return df_super_situation_pivot


df_big_r_situation = pd.DataFrame()
df_super_r_situation = pd.DataFrame()
for i in pd.date_range((datetime.datetime.strptime(date, '%Y-%m-%d') - delta).strftime('%Y-%m-%d'), date):
    # print(i)
    df_big_r_situation = df_big_r_situation.append(big_r_situation(i))
    df_super_r_situation = df_super_r_situation.append(super_r_situation(i))


# 2.10 大R超R逗豆消耗场景
def doudou_big_r(date):
    df_doudou_big_r = ssql('''SELECT date,  CASE WHEN reason LIKE 'fish%' THEN 'fish'
                          WHEN reason LIKE 'mahjong_%' THEN 'mahjong'
                          WHEN reason LIKE 'bet_guess_%' then 'bet_guess'
                          WHEN reason LIKE 'melee_balance_%' then 'melee' 
                          else '其他'end as reason, -sum(amount)/1000000 amount 
    from 
    (select date, distinct_id, reason, amount
    from events 
    where event = 'addItem'
    and item_id = 1
    and date ='{date}') t1
    join 
    (select distinct_id
    from events
    where event = 'pay'
    and date between '{date}'- interval '29' day and '{date}'
    group by 1
    having sum(pay) >= 10000 
    and sum(pay) < 25000) t2
    on t1.distinct_id = t2.distinct_id
    group by 1, 2
    order by 1 '''.format(date=date))
    df_doudou_big_r_pivot = df_doudou_big_r.pivot_table(index='date', columns='reason').fillna(0)  # .to_clipboard()
    df_doudou_big_r_pivot.columns = df_doudou_big_r_pivot.columns.droplevel()
    return df_doudou_big_r_pivot


def doudou_super_r(date):
    df_doudou_super_r = ssql('''SELECT date,  CASE WHEN reason LIKE 'fish%' THEN 'fish'
                          WHEN reason LIKE 'mahjong_%' THEN 'mahjong'
                          WHEN reason LIKE 'bet_guess_%' then 'bet_guess'
                          WHEN reason LIKE 'melee_balance_%' then 'melee' 
                          else '其他'end as reason, -sum(amount)/1000000 amount 
    from 
    (select date, distinct_id, reason, amount
    from events 
    where event = 'addItem'
    and item_id = 1
    and date ='{date}') t1
    join 
    (select distinct_id
    from events
    where event = 'pay'
    and date between '{date}'- interval '29' day and '{date}'
    group by 1
    having sum(pay) >= 25000) t2
    on t1.distinct_id = t2.distinct_id
    group by 1, 2
    order by 1  '''.format(date=date))
    df_doudou_super_r_pivot = df_doudou_super_r.pivot_table(index='date', columns='reason').fillna(0)  # .to_clipboard()
    df_doudou_super_r_pivot.columns = df_doudou_super_r_pivot.columns.droplevel()
    return df_doudou_super_r_pivot


df_doudou_big_r = pd.DataFrame()
df_doudou_super_r = pd.DataFrame()
for i in pd.date_range((datetime.datetime.strptime(date, '%Y-%m-%d') - delta).strftime('%Y-%m-%d'), date):
    # print(i)
    df_doudou_big_r = df_doudou_big_r.append(doudou_big_r(i))
    df_doudou_super_r = df_doudou_super_r.append(doudou_super_r(i))

# In[3]:


# #自动化
original_stdout = sys.stdout  # Save a reference to the original standard output

with open('filename.txt', 'w') as f:
    sys.stdout = f  # Change the standard output to the file we created.
    # 当天收入及环比变化
    f.writelines()
    print(df_all.loc[1, 'date'])
    print('***昨日充值概览：***')
    print('1.收入为', df_all.loc[1, 'pay'], '万元，', end='')
    t1 = '较前一日{trend}了'.format(trend='增长' if (gap(df_all['pay'])[1]) > 0 else '下降') + str(
        abs(gap(df_all['pay'])[1])) + '万元，' + '{trend}幅度为'.format(
        trend='增长' if (gap(df_all['pay'])[1]) > 0 else '下降') + str(change(df_all['pay'])[1]) + '%'
    print(t1)

    # 充值总人数及金额
    t2 = '2.充值总人数为' + str(math.ceil(df_all.loc[1, 'pay_users'])) + '人,' + '较前一日{trend}了'.format(
        trend='增长' if (gap(df_all['pay_users'])[1]) > 0 else '下降') + str(
        math.ceil(abs(gap(df_all['pay_users']))[1])) + '人，ARPPU为' + str(
        round(df_all.loc[1, 'arppu'], 2)) + '元,' + '较前一日{trend}了'.format(
        trend='增长' if (gap(df_all['arppu'])[1]) > 0 else '下降') + str(int(abs(gap(df_all['arppu'])[1]))) + '元'
    print(t2)

    # 大R超R充值情况
    t3 = '3.大R用户数为' + str(math.ceil(df_all.loc[1, 'big_r'])) + '人，' + '较前一日{trend}'.format(
        trend='增长' if (gap(df_all['big_r'])[1]) > 0 else '下降') + str(
        math.ceil(abs(gap(df_all['big_r'])[1]))) + '人。充值大R人数为' + str(
        math.ceil(df_all.loc[1, 'big_r'])) + '人，' + '较前一日{trend}'.format(
        trend='增长' if (gap(df_all['pay_big_r'])[1]) > 0 else '下降') + str(
        math.ceil(abs(gap(df_all['pay_big_r'])[1]))) + '人。大R总充值金额为' + str(
        df_all.loc[1, 'total_pay_big_r']) + '万元，' + '较前一日{trend}'.format(
        trend='增长' if (gap(df_all['total_pay_big_r'])[1]) > 0 else '下降') + str(
        abs(gap(df_all['total_pay_big_r'])[1])) + '万元'
    print(t3)

    t4 = '4.超R用户数为' + str(math.ceil(df_all.loc[1, 'super_r'])) + '人，' + '较前一日{trend}'.format(
        trend='增长' if (gap(df_all['super_r'])[1]) > 0 else '下降') + str(
        math.ceil(abs(gap(df_all['super_r'])[1]))) + '人。充值超R人数为' + str(
        math.ceil(df_all.loc[1, 'super_r'])) + '人，' + '较前一日{trend}'.format(
        trend='增长' if (gap(df_all['pay_super_r'])[1]) > 0 else '下降') + str(
        math.ceil(abs(gap(df_all['pay_super_r'])[1]))) + '人。超R总充值金额为' + str(
        df_all.loc[1, 'total_pay_super_r']) + '万元，' + '较前一日{trend}'.format(
        trend='增长' if (gap(df_all['total_pay_super_r'])[1]) > 0 else '下降') + str(
        abs(gap(df_all['total_pay_super_r'])[1])) + '万元'
    print(t4)

    # 变化幅度是否>5%
    if abs(change(df_all['pay'])[1]) < 5:
        print('**昨日波动幅度<5%，属于正常波动**')
    else:
        # 变化是否受DAU影响
        # print ("\n" )
        print('***收入变动原因排查：***')
        if abs(change(df_all['dau'])[1]) > 5 and abs(change(df_all['arpu'])[1]) < 5 and gap(df_all['dau'])[1] / \
                gap(df_all['pay'])[1] > 0:
            t5 = '收入受DAU变化影响，DAU{trend}'.format(trend='增长' if (gap(df_all['dau'])[1]) > 0 else '下降') + str(
                math.ceil(abs(gap(df_all['dau'])[1]))) + '人'
            print(t5)

        print('  **钻石消耗细分：**')

        # 剩余值的变化
        # df1['consume'] = df1['买礼物'] +df1['battlepass']+df1['买礼物券']+df1['兑换逗豆']+df1['其他']
        # gap(df_all['consume'])[1]/gap(df_all['pay'])[1]

        # 钻石兑换各种价值
        cause_battlepass = gap(df_all['battlepass'])[1] / gap(df_all['pay'])[1]
        cause_doudou = gap(df_all['doudou'])[1] / gap(df_all['pay'])[1]
        cause_gift = gap(df_all['gift'])[1] / gap(df_all['pay'])[1]
        cause_gift_coupon = gap(df_all['gift_coupon'])[1] / gap(df_all['pay'])[1]
        cause_others = gap(df_all['其他'])[1] / gap(df_all['pay'])[1]

        if cause_battlepass > 0.3:
            print('    有' + str(math.ceil(cause_battlepass * 100)) + "%" + '【养成类游戏道具】原因，钻石兑换养成类游戏道具较前一日变化' + str(
                gap(df_all['battlepass'])[1]) + '万元')
            cause_battlepass_big_r = gap(df_big_r_situation['battlepass'])[1] / gap(df_all['battlepass'])[1]
            cause_battlepass_super_r = gap(df_super_r_situation['battlepass'])[1] / gap(df_all['battlepass'])[1]
            if cause_battlepass_big_r > 0.3:
                print('    - 受到大R用户群影响,大R养成类游戏道具较前一日{trend}'.format(
                    trend='增长' if gap(df_big_r_situation['battlepass']) >= 0 else '下降'),
                      abs(gap(df_big_r_situation['battlepass'])), '万元')
            if cause_battlepass_super_r > 0.3:
                print('    - 受到超R用户群影响,超R养成类游戏道具较前一日{trend}'.format(
                    trend='增长' if gap(df_super_r_situation['battlepass']) >= 0 else '下降'),
                      abs(gap(df_super_r_situation['battlepass'])), '万元')
            if cause_battlepass_big_r <= 0.3 and cause_battlepass_super_r <= 0.3:
                print('    - 大R超R用户群变化不大,其他用户钻石买养成类游戏道具较前一日{trend}'.format(
                    trend='增长' if gap(df_all['battlepass'])[1] - gap(df_super_r_situation['battlepass'])[1] -
                                  gap(df_big_r_situation['battlepass'])[1] >= 0 else '下降'),
                      abs(round(gap(df_all['battlepass'])[1] - gap(df_super_r_situation['battlepass'])[1] -
                                gap(df_big_r_situation['battlepass'])[1], 2), '万元'))

        if cause_gift > 0.3:
            print('    有' + str(math.ceil(cause_gift * 100)) + "%" + '钻石兑换【礼物】原因，钻石兑换礼物较前一日{trend}'.format(
                trend='增长' if gap(df_all['gift'])[1] >= 0 else '减少') +
                  str(abs(gap(df_all['gift'])[1])) + '万元')
            cause_gift_big_r = gap(df_big_r_situation['gift'])[1] / gap(df_all['gift'])[1]
            cause_gift_super_r = gap(df_super_r_situation['gift'])[1] / gap(df_all['gift'])[1]
            if cause_gift_big_r > 0.3:
                print('    - 受到大R用户群影响,大R钻石买礼物价值较前一日{trend}'.format(
                    trend='增长' if gap(df_big_r_situation['gift'])[1] >= 0 else '减少'),
                      abs(gap(df_big_r_situation['gift'])[1]), '万元')
            if cause_gift_super_r > 0.3:
                print('    - 受到超R用户群影响,超R钻石买礼物价值较前一日{trend}'.format(
                    trend='增长' if gap(df_super_r_situation['gift'])[1] >= 0 else '减少'),
                      abs(gap(df_super_r_situation['gift'])[1]), '万元')
            if cause_gift_big_r <= 0.3 and cause_gift_super_r <= 0.3:
                print('    - 大R超R用户群变化不大,其他用户钻石买礼物较前一日{trend}'.format(
                    trend='增长' if gap(df_all['gift'])[1] - gap(df_super_r_situation['gift'])[1] -
                                  gap(df_big_r_situation['gift'])[1] >= 0 else '减少'),
                      abs(round(gap(df_all['gift'])[1] - gap(df_super_r_situation['gift'])[1] -
                                gap(df_big_r_situation['gift'])[1], 2)), '万元')

        if cause_gift_coupon > 0.3:
            print('    有' + str(math.ceil(cause_gift_coupon * 100)) + "%" + '钻石兑换【礼物券】原因，钻石兑换礼物券较前一日{trend}'.format(
                trend='增长' if gap(df_all['gift_coupon'])[1] >= 0 else '减少') + str(
                abs(gap(df_all['gift_coupon'])[1])) + '万元')
            cause_gift_coupon_big_r = gap(df_big_r_situation['gift_coupon'])[1] / gap(df_all['gift_coupon'])[1]
            cause_gift_coupon_super_r = gap(df_super_r_situation['gift_coupon'])[1] / gap(df_all['gift_coupon'])[1]
            if cause_gift_coupon_big_r > 0.3:
                print('    - 受到大R用户群影响,大R钻石买礼物券价值较前一日{trend}'.format(
                    trend='增长' if gap(df_big_r_situation['gift_coupon'])[1] >= 0 else '减少'),
                      abs(gap(df_big_r_situation['gift_coupon'])[1]), '万元')
            if cause_gift_coupon_super_r > 0.3:
                print('    - 受到超R用户群影响,超R钻石买礼物券价值较前一日{trend}'.format(
                    trend='增长' if gap(df_super_r_situation['gift_coupon'])[1] >= 0 else '减少'),
                      abs(gap(df_super_r_situation['gift_coupon'])[1], '万元'))
            if cause_gift_coupon_big_r <= 0.3 and cause_gift_coupon_super_r <= 0.3:
                print('    - 大R超R用户群变化不大,其他用户钻石买礼物券较前一日{trend}'.format(
                    trend='增长' if gap(df_all['gift_coupon'])[1] - gap(df_super_r_situation['gift_coupon'])[1] -
                                  gap(df_big_r_situation['gift_coupon'])[1] >= 0 else '减少'),
                      abs(round(gap(df_all['gift_coupon'])[1] - gap(df_super_r_situation['gift_coupon'])[1] -
                                gap(df_big_r_situation['gift_coupon'])[1], 2)), '万元')

        if cause_others > 0.3:
            print('    有' + str(math.ceil(cause_others * 100)) + "%" + '钻石兑换【运营活动、金币、会员】原因，{trend}'.format(
                trend='增长' if gap(df_all['其他'])[1] >= 0 else '减少') + str(abs(gap(df_all['其他'])[1])) + '万元')
            cause_other_big_r = gap(df_big_r_situation['其他'])[1] / gap(df_all['其他'])[1]
            cause_other_super_r = gap(df_super_r_situation['其他'])[1] / gap(df_all['其他'])[1]
            if cause_other_big_r > 0.3:
                print('    - 受到大R用户群影响,大R运营活动、金币、会员较前一日{trend}'.format(
                    trend='增长' if gap(df_big_r_situation['其他'])[1] >= 0 else '减少'),
                      abs(gap(df_big_r_situation['其他'])[1]), '万元')
            if cause_other_super_r > 0.3:
                print('    - 受到超R用户群影响,超R运营活动、金币、会员较前一日{trend}'.format(
                    trend='增长' if gap(df_super_r_situation['其他'])[1] >= 0 else '减少'),
                      abs(gap(df_super_r_situation['其他'])[1]), '万元')
            if cause_other_big_r <= 0.3 and cause_other_super_r <= 0.3:
                print('    - 大R超R用户群变化不大,其他用户运营活动、金币、会员较前一日{trend}'.format(
                    trend='增长' if gap(df_all['其他'])[1] - gap(df_super_r_situation['其他'])[1] -
                                  gap(df_big_r_situation['其他'])[1] >= 0 else '减少'),
                      abs(round(
                          gap(df_all['其他'])[1] - gap(df_super_r_situation['其他'])[1] - gap(df_big_r_situation['其他'])[1],
                          2)), '万元')

        if cause_doudou > 0.3:
            print('    有' + str(math.ceil(cause_doudou * 100)) + "%" + '钻石兑换【逗豆】原因，钻石兑换逗豆较前一日{trend}'.format(
                trend='增长' if gap(df_all['doudou'])[1] >= 0 else '减少') + str(abs(gap(df_all['doudou'])[1])) + '万元')

            # 如果钻石兑换逗豆价值和逗豆消耗变化趋势一致
            if gap(df_all['doudou'])[1] / gap(df_doudou_pivot['doudou'])[1] > 0:

                # 细分大乱斗、捕鱼、猜猜乐、麻将中的大额消耗变化
                print('        **逗豆消耗细分：**')
                cause_melee = gap(df_doudou_pivot['melee'])[1] / gap(df_doudou_pivot['doudou'])[1]
                cause_fish = gap(df_doudou_pivot['fish'])[1] / gap(df_doudou_pivot['doudou'])[1]
                cause_guess = gap(df_doudou_pivot['bet_guess'])[1] / gap(df_doudou_pivot['doudou'])[1]
                cause_majiang = gap(df_doudou_pivot['mahjong'])[1] / gap(df_doudou_pivot['doudou'])[1]

                if cause_melee > 0.3:
                    print('            逗豆变化有' + str(
                        math.ceil(cause_melee * 100)) + "%" + '【大乱斗】原因，用户在大乱斗中消耗逗豆较前一日{trend}'.format(
                        trend='增长' if gap(df_doudou_pivot['melee'])[1] >= 0 else '减少') +
                          str(abs(gap(df_doudou_pivot['melee'])[1])) + '百万逗豆')

                    cause_melee_big_r = gap(df_doudou_big_r['melee'])[1] / gap(df_doudou_pivot['melee'])[1]
                    cause_melee_super_r = gap(df_doudou_super_r['melee'])[1] / gap(df_doudou_pivot['melee'])[1]
                    if cause_melee_big_r > 0.3:
                        print('        - 受到大R用户群影响,大R大乱斗逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_big_r['melee'])[1] >= 0 else '减少'),
                              abs(gap(df_doudou_big_r['melee'])[1]), '百万逗豆')
                    if cause_melee_super_r > 0.3:
                        print('        - 受到超R用户群影响,超R大乱斗逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_super_r['melee'])[1] >= 0 else '减少'),
                              abs(gap(df_doudou_super_r['melee'])[1]), '百万逗豆')
                    if cause_melee_big_r <= 0.3 and cause_melee_super_r <= 0.3:
                        print('        - 大R超R用户群变化不大,其他用户大乱斗逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_pivot['melee'])[1] - gap(df_doudou_big_r['melee'])[1] -
                                          gap(df_doudou_super_r['melee'])[1] >= 0 else '减少'),
                              abs(round(gap(df_doudou_pivot['melee'])[1] - gap(df_doudou_big_r['melee'])[1] -
                                        gap(df_doudou_super_r['melee'])[1], 2)), '百万逗豆')

                if cause_fish > 0.3:
                    print('        逗豆变化有' + str(
                        math.ceil(cause_fish * 100)) + "%" + '【捕鱼】原因，用户在捕鱼中消耗逗豆较前一日{trend}'.format(
                        trend='增长' if gap(df_doudou_pivot['fish'])[1] >= 0 else '减少') + str(
                        abs(gap(df_doudou_pivot['fish'])[1])) + '百万逗豆')

                    cause_fish_big_r = gap(df_doudou_big_r['fish'])[1] / gap(df_doudou_pivot['fish'])[1]
                    cause_fish_super_r = gap(df_doudou_super_r['fish'])[1] / gap(df_doudou_pivot['fish'])[1]
                    if cause_fish_big_r > 0.3:
                        print('        - 受到大R用户群影响,大R捕鱼逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_big_r['fish'])[1] >= 0 else '减少'),
                              abs(gap(df_doudou_big_r['fish'])[1]), '百万逗豆')
                    if cause_fish_super_r > 0.3:
                        print('        - 受到超R用户群影响,超R捕鱼逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_big_r['fish'])[1] >= 0 else '减少'),
                              abs(gap(df_doudou_super_r['fish'])[1]), '百万逗豆')
                    if cause_fish_big_r <= 0.3 and cause_fish_super_r <= 0.3:
                        print('        - 大R超R用户群变化不大,其他用户捕鱼逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_pivot['fish'])[1] - gap(df_doudou_big_r['fish'])[1] -
                                          gap(df_doudou_super_r['fish'])[1] >= 0 else '减少'),
                              abs(round(gap(df_doudou_pivot['fish'])[1] - gap(df_doudou_big_r['fish'])[1] -
                                        gap(df_doudou_super_r['fish'])[1], 2)), '百万逗豆')

                if cause_guess > 0.3:
                    print('        逗豆变化有' + str(math.ceil(
                        cause_guess * 100)) + "%" + '【猜猜乐】原因，用户在猜猜乐                          中消耗逗豆较前一日{trend}'.format(
                        trend='增长' if gap(df_doudou_pivot['bet_guess'])[1] >= 0 else '减少') + str(
                        abs(gap(df_doudou_pivot['bet_guess'])[1])) + '百万逗豆')

                    cause_bet_guess_big_r = gap(df_doudou_big_r['bet_guess'])[1] / gap(df_doudou_pivot['bet_guess'])[1]
                    cause_bet_guess_super_r = gap(df_doudou_super_r['bet_guess'])[1] / \
                                              gap(df_doudou_pivot['bet_guess'])[1]
                    if cause_bet_guess_big_r > 0.3:
                        print('        - 受到大R用户群影响,大R猜猜乐逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_big_r['bet_guess'])[1] >= 0 else '减少'),
                              abs(gap(df_doudou_big_r['bet_guess'])[1]), '百万逗豆')
                    if cause_bet_guess_super_r > 0.3:
                        print('        - 受到超R用户群影响,超R猜猜乐逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_super_r['bet_guess'])[1] >= 0 else '减少'),
                              abs(gap(df_doudou_super_r['bet_guess'])[1]), '百万逗豆')
                    if cause_bet_guess_big_r <= 0.3 and cause_bet_guess_super_r <= 0.3:
                        print('        - 大R超R用户群变化不大,其他用户猜猜乐逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_pivot['bet_guess'])[1] - gap(df_doudou_big_r['bet_guess'])[1] -
                                          gap(df_doudou_super_r['bet_guess'])[1] >= 0 else '减少'),
                              abs(round(gap(df_doudou_pivot['bet_guess'])[1] - gap(df_doudou_big_r['bet_guess'])[1] -
                                        gap(df_doudou_super_r['bet_guess'])[1], 2)), '百万逗豆')

                if cause_majiang > 0.3:
                    print('        逗豆变化有' + str(
                        math.ceil(cause_majiang * 100)) + "%" + '【麻将】原因，用户在麻将中消耗逗豆较前一日{trend}'.format(
                        trend='增长' if gap(df_doudou_pivot['mahjong'])[1] >= 0 else '减少') + str(
                        abs(gap(df_doudou_pivot['mahjong'])[1])) + '百万逗豆')

                    cause_mahjong_big_r = gap(df_doudou_big_r['mahjong'])[1] / gap(df_doudou_pivot['mahjong'])[1]
                    cause_mahjong_super_r = gap(df_doudou_super_r['mahjong'])[1] / gap(df_doudou_pivot['mahjong'])[1]
                    if cause_mahjong_big_r > 0.3:
                        print('        - 受到大R用户群影响,大R麻将逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_big_r['mahjong'])[1] >= 0 else '减少'),
                              abs(gap(df_doudou_big_r['mahjong'])[1]), '百万逗豆')
                    if cause_mahjong_super_r > 0.3:
                        print('        - 受到超R用户群影响,超R麻将逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_super_r['mahjong'])[1] >= 0 else '减少'),
                              abs(gap(df_doudou_super_r['mahjong'])[1]), '百万逗豆')
                    if cause_mahjong_big_r <= 0.3 and cause_mahjong_super_r <= 0.3:
                        print('        - 大R超R用户群变化不大,其他用户麻将逗豆消耗较前一日{trend}'.format(
                            trend='增长' if gap(df_doudou_pivot['mahjong'])[1] - gap(df_doudou_big_r['mahjong'])[1] -
                                          gap(df_doudou_super_r['mahjong'])[1] >= 0 else '减少'),
                              abs(round(gap(df_doudou_pivot['mahjong'])[1] - gap(df_doudou_big_r['mahjong'])[1] -
                                        gap(df_doudou_super_r['mahjong'])[1], 2)), '百万逗豆')

    for j in range(len(df_activity_pivot.columns)):
        if np.isnan(df_activity_pivot.iloc[1, j]) == False and df_activity_pivot.iloc[1, j] > 1:
            print("***昨日运营活动有：***", df_activity_pivot.columns[j], '收入为', df_activity_pivot.iloc[1, j], '万元')

sys.stdout = original_stdout  # Reset the standard output to its original value

# In[4]:


from dingtalkchatbot.chatbot import DingtalkChatbot

# In[5]:


# # 测试群
# webhook = 'https://oapi.dingtalk.com/robot/send?access_token=6610f8094f39ed963332bb797793ee0810fac631cf913eb0acb4c486ea1c0c8c'
# secret = 'SEC3ae3a522183c8593af20b5989ecb13e659a6149443aa082e68efa9a5e87ae85b'


# In[40]:


# 收入共建群
webhook = 'https://oapi.dingtalk.com/robot/send?access_token=2606c23eaf70851235a10785081a8fedcc72d210c9379c9b960c32d571372b8a'
secret = 'SEC2fe3fce80cc0a5b2de41423c540b8f58c2f2c393a7c2ec28c75d9bdd0062939e'

# In[6]:


xiaoding = DingtalkChatbot(webhook, secret=secret)

# In[7]:


string = ''
f2 = open('filename.txt', "r")
lines = f2.readlines()
string = string.join(lines)
xiaoding.send_text(msg=string)
