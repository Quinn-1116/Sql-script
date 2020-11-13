 任务完成： 存活状态下完成 死亡状态下完成 --存活状态下任务的完成率

SELECT t1.date,
       t1.mission_name,
       t1.distribute_num,
       t4.finish_num,
       t2.alive_finish_num,
       t3.killed_finish_num
FROM
  (SELECT date, mission_name,
                count(distinct_id) AS distribute_num
   FROM events
   WHERE event = 'mission'
     AND SOURCE = 'killer'
     AND missionOp = 'distribute'
     AND date BETWEEN '2020-10-20' AND current_date()
   GROUP BY 1,
            2)t1
JOIN
  (SELECT date, mission_name,
                count(distinct_id) AS alive_finish_num
   FROM events
   WHERE event = 'mission'
     AND SOURCE = 'killer'
     AND label = 'alive'
     AND missionOp = 'finish'
     AND date BETWEEN '2020-10-20' AND current_date()
   GROUP BY 1,
            2)t2 ON t1.date = t2.date
AND t1.mission_name = t2.mission_name
JOIN
  (SELECT date, mission_name,
                count(distinct_id) AS killed_finish_num
   FROM events
   WHERE event = 'mission'
     AND SOURCE = 'killer'
     AND label = 'killed'
     AND missionOp = 'finish'
     AND date BETWEEN '2020-10-20' AND current_date()
   GROUP BY 1,
            2)t3 ON t1.date = t3.date
AND t1.mission_name = t3.mission_name
JOIN
  (SELECT date, mission_name,
                count(distinct_id) AS finish_num
   FROM events
   WHERE event = 'mission'
     AND SOURCE = 'killer'
     AND missionOp = 'finish'
     AND date BETWEEN '2020-10-20' AND current_date()
   GROUP BY 1,
            2)t4 ON t1.date = t4.date
AND t1.mission_name = t4.mission_name
order by 1,2




SELECT time,
       mission_name,
       label,
       missionLinkId,
       missionOp,
       SOURCE
FROM events
WHERE event = 'mission'
  AND SOURCE = 'killer'
  AND date = current_date()
ORDER BY time DESC