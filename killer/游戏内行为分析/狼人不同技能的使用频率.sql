SELECT date, POSITION,
             count(1) AS kill_num
FROM events
WHERE event = 'action'
  AND date BETWEEN '2020-10-20' AND current_date()
  AND SOURCE = 'killer'
  AND op_type = 'kill'
  AND game_character = 'impostor'
GROUP BY 1,
         2
ORDER BY 1,
         3 DESC



SELECT date, item_name,
             count(1) AS sabotage_num
FROM events
WHERE event = 'action'
  AND date BETWEEN '2020-10-20' AND current_date()
  AND SOURCE = 'killer'
  AND op_type = 'sabotage'
  AND game_character = 'impostor'
GROUP BY 1,
         2
ORDER BY 1,
         3 DESC


 