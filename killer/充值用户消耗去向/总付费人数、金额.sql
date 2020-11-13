SELECT sum(pay)
FROM events
WHERE event = 'pay'
  AND date BETWEEN '2020-10-16' AND current_date()
  AND appId IN ('20014',
                '30015')



  SELECT count(distinct distinct_id)
FROM events
WHERE event = 'pay'
  AND date BETWEEN '2020-10-16' AND current_date()
  AND appId IN ('20014',
                '30015')