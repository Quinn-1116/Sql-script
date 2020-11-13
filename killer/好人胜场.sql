 --好人胜场

SELECT count(t8.match_id)AS total,
       count(t7.match_id) AS crew_win,
       count(t7.match_id)/count(t8.match_id) AS p
FROM
  (SELECT date,match_id
   FROM events
   WHERE event = 'gameOver'
     AND gameTypeId = 1800
     AND game_result = 'win'
     AND game_character = 'crewmate'
     AND date = current_date()
   GROUP BY 1,
            2)t7
RIGHT JOIN
  (SELECT t5.date, t5.match_id
   FROM
     (SELECT date,match_id
      FROM events
      WHERE event = 'gameOver'
        AND gameTypeId = 1800
        AND date = current_date()
        AND time >='2020-10-26 13:00:00'
      GROUP BY 1,
               2)t5
   LEFT JOIN
     (SELECT t1.match_id--双方都获胜的match_id·

      FROM
        (SELECT date,match_id
         FROM events
         WHERE event = 'gameOver'
           AND gameTypeId = 1800
           AND game_result = 'win'
           AND game_character = 'crewmate'
           AND date = current_date()
           AND time >='2020-10-26 13:00:00'
         GROUP BY 1,
                  2) t1
      JOIN
        (SELECT date,match_id
         FROM events
         WHERE event = 'gameOver'
           AND gameTypeId = 1800
           AND game_result = 'win'
           AND game_character = 'impostor'
           AND date = current_date()
           AND time >='2020-10-26 13:00:00'
         GROUP BY 1,
                  2)t2 ON t1.date = t2.date
      AND t1.match_id = t2.match_id
      UNION 
      SELECT t3.match_id
      FROM
        (SELECT date,match_id--双方都输的match_id

         FROM events
         WHERE event = 'gameOver'
           AND gameTypeId = 1800
           AND game_result = 'lose'
           AND game_character = 'crewmate'
           AND date = current_date()
           AND time >='2020-10-26 13:00:00'
         GROUP BY 1,
                  2) t3
      JOIN
        (SELECT date, match_id
         FROM events
         WHERE event = 'gameOver'
           AND gameTypeId = 1800
           AND game_result = 'lose'
           AND game_character = 'impostor'
           AND date = current_date()
           AND time >='2020-10-26 13:00:00'
         GROUP BY 1,
                  2)t4 ON t3.date = t4.date
      AND t3.match_id = t4.match_id)t6 ON t5.match_id = t6.match_id
   WHERE t6.match_id IS NULL) t8 ON t7.match_id = t8.match_id