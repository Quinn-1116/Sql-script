
SELECT time,
       distinct_id,
       event,
       to_uid,
       friendID,
       gameTypeId,
       duration,
       game_result,
       game_character,
       reason
FROM events
WHERE distinct_id = '111046838'
  AND date = current_date()
  AND event in('gameStart','addFriendNew','gameOver','action','mission','roomAllocate','enterRoom')
ORDER BY time DESC 用户通过搜索进入房间后，后面接着通过搜索进入房间



 


SELECT t1.date,count(t1.distinct_id),
               count(t2.distinct_id),
               count(t2.distinct_id)/count(t1.distinct_id) AS r_1
FROM
  (SELECT date, distinct_id
   FROM events
   WHERE event = 'enterRoom'
     AND date BETWEEN '2020-10-16' AND current_date()
     AND roomEntrance = 'gc_join_1800'
     AND gameTypeId = 1800
     group by 1,2) t1
LEFT JOIN
  (SELECT date, distinct_id
   FROM events
   WHERE event = 'enterRoom'
     AND date BETWEEN '2020-10-16' AND current_date()
     AND roomEntrance = 'gc_join_1800'--普通匹配
     AND gameTypeId = 1800
     group by 1,2) t2 ON t1.distinct_id = t2.distinct_id
AND datediff(t2.date,t1.date) = 1
GROUP BY 1
order by 1