With login as (
  SELECT 
  E_mail as user_id, 
  DATE_TRUNC(Date, month) as months_active,
  min(I_am_a) as profession
  FROM `pristine-flames-216323.Stratovan.logins` lg
  Left join `pristine-flames-216323.Stratovan.ProSurgical` ps
  on lg.e_mail = ps.Email_Address
  where lg.appid = 5
  and i_am_a = 'Surgeon'
  group by 1,2
)

,cohorts as (
  SELECT
  user_id,
  Min(months_active) as cohort
  FROM login
  GROUP BY 1
)

, retention as (
  SELECT
  user_id,
  months_active,
  COUNT(*) AS month_actives_days
  FROM login
  GROUP BY 1,2
)

SELECT
cohort,
m.months_active AS month_actual,
count(m.user_id) AS cnt_user_retained,
RANK() OVER (PARTITION BY cohort ORDER BY months_active ASC)-1 AS month_rank,
RANK() OVER (PARTITION BY cohort ORDER BY months_active DESC)-1 AS month_rank_trend
FROM cohorts c
LEFT JOIN retention m
ON c.user_id = m.user_id
GROUP BY 1,2
ORDER BY 1,2;
