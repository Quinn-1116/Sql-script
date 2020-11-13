
SELECT t1.date,
       t2.item_type_name,
       t2.item_name,
       count(t1.distinct_id)
FROM
  (SELECT date,distinct_id
   FROM events
   WHERE event = 'register'
     AND date BETWEEN '2020-08-15' AND '2020-08-30'
   GROUP BY 1,
            2)t1
LEFT JOIN
  (SELECT date,distinct_id,
               item_type_name,
               item_name,
               reason
   FROM events
   WHERE event = 'addItem'
     AND date BETWEEN '2020-08-15' AND '2020-08-30'
     AND amount>0
     AND item_id !=1
     AND reason in('usePropBuy_doudou','diamond_exchange','user_gold_buy')
   GROUP BY 1,
            2,
            3,
            4,
            5) t2 ON t1.date = t2.date
AND t1.distinct_id = t2.distinct_id
WHERE t2.item_name IS NOT NULL
GROUP BY 1,
         2,
         3
ORDER BY 1