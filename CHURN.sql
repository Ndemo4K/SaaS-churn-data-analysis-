--  the commom SaaS metrics are ; 
-- customer churn rate - the percentage of custmers who leave.
-- revenue churn rate - the percentage of revenue lost
-- retention churn - the percentage of customers who renew 
-- the intention of this analysis is to understand why custmers leave, to help businesses understand and have insight.
-- i will first start by discussing assumptions as to why customers will leave or stop using a certain service 
-- some of the hypotheses are;
-- 1; maybe they stopped paying because they are unhappy about the pricing 
-- 2; maybe because they dont find importance in the service anymore
-- 3; maybe they still pay but dont use it (this could be an opportunity for various business decisions like upselling or customer success outreach)
-- the discussed assumptions are all opportunities for the company to  improve the service
-- i'll also go ahead and create different personalities to further narrow down the churn the data will define
-- 1: financial churn - stopped paying in the last 90 days
-- 2: engagement churn - havent logged in for 90 days 
-- 3: silent churn - still paying but not logging in
-- 4: healthy customer - still paying and actively logging insert

-- lets find the financial churn(those who stopped paying)- last payment date for each customer 
select customer_id,
max(transaction_date) as last_payment_date
from transactions
group by customer_id;

-- filter out these customers who havent made a pyment in the last 90 days 

select customer_id,
	max(transaction_date) as last_payment_date
from transactions
group by customer_id
HAVING max(transaction_date) < (CURRENT_DATE - INTERVAL 90 DAY);

-- lets find engagement churn (who stopped logging in)
select customer_id,
max(event_date) as last_login_date
from user_activity
where event_type = 'login'
group by customer_id;

-- filter users who haven't logged in for 90+ days

select customer_id,
max(event_date) as last_login_date
from user_activity
where event_type = 'login'
group by customer_id
HAVING max(event_date) < (CURRENT_DATE - INTERVAL 90 DAY);

-- silent churn category(who [pays doesn't log in)

select t.customer_id,
max(t.transaction_date) as last_payment_date,
max(event_date) as last_login_date
from transactions t
left join user_activity ua 
	on t.customer_id = ua.customer_id
group by t.customer_id;

-- lets filter these by those who still pay but dont login


select t.customer_id,
max(t.transaction_date) as last_payment_date,
max(event_date) as last_login_date
from transactions t
left join user_activity ua 
	on t.customer_id = ua.customer_id
group by t.customer_id
having max(t.transaction_date)<= (current_date - interval 90 day)
and max(ua.event_date)< (current_date - interval 90 day) ;

-- combine everything 

WITH churn_data AS (
    SELECT 
        c.customer_id,
        c.name,
        c.email,
        fc.customer_id AS financial_churn_flag
    FROM customers AS c
    LEFT JOIN (
        SELECT customer_id
        FROM transactions
        GROUP BY customer_id
        HAVING MAX(transaction_date) < (CURRENT_DATE - INTERVAL 90 DAY)
    ) AS fc
        ON c.customer_id = fc.customer_id
)
SELECT *
FROM churn_data;

select version();


DESC customers;
ALTER TABLE customers 
CHANGE `ï»¿customer_id` customer_id INT;


WITH churn_data AS (
    SELECT 
        c.customer_id,
        c.name,
        c.email,
	case
        when fc.customer_id is not null then 'financial_churn_flag'
        when ec.customer_id is not null then 'engagement_churn_flag'
        when sc.customer_id is not null then 'silent_churn_flag'
        else 'active'
        end as churn_type
    FROM customers AS c
    LEFT JOIN (
        SELECT customer_id
        FROM transactions
        GROUP BY customer_id
        HAVING MAX(transaction_date) < (CURRENT_DATE - INTERVAL 90 DAY)
    ) AS fc
        ON c.customer_id = fc.customer_id
	left join(
        select customer_id
        from user_activity
        where event_type = 'login'
        group by customer_id
        having max(event_date) < (current_date - interval 90 day)
        )ec on c.customer_id = ec.customer_id
	left join(
    select t.customer_id
    from transactions t 
    left join user_activity ua on t.customer_id = ua.customer_id
    group by t.customer_id
    having max(t.transaction_date)>=(current_date - interval 90 day)
    and max(ua.event_date) < (current_date - interval 90 day)
    ) as sc on c.customer_id = sc.customer_id
        )

SELECT *
FROM churn_data;


WITH churn_data AS (
    SELECT 
        c.customer_id,
        c.name,
        c.email,
        CASE
            WHEN fc.customer_id IS NOT NULL THEN 'financial_churn_flag'
            WHEN ec.customer_id IS NOT NULL THEN 'engagement_churn_flag'
            WHEN sc.customer_id IS NOT NULL THEN 'silent_churn_flag'
            ELSE 'active'
        END AS churn_type
    FROM customers AS c

    LEFT JOIN (
        SELECT customer_id
        FROM transactions
        GROUP BY customer_id
        HAVING MAX(transaction_date) < (CURRENT_DATE - INTERVAL 90 DAY)
    ) AS fc
        ON c.customer_id = fc.customer_id
        
    LEFT JOIN (
        SELECT customer_id
        FROM user_activity
        WHERE event_type = 'login'
        GROUP BY customer_id
        HAVING MAX(event_date) < (CURRENT_DATE - INTERVAL 90 DAY)
    ) ec
        ON c.customer_id = ec.customer_id
        
    LEFT JOIN (
        SELECT 
            t.customer_id
        FROM transactions t
        LEFT JOIN user_activity ua 
               ON t.customer_id = ua.customer_id
        GROUP BY t.customer_id
        HAVING 
            MAX(t.transaction_date) >= (CURRENT_DATE - INTERVAL 90 DAY)
            AND COALESCE(MAX(ua.event_date), '1900-01-01') < (CURRENT_DATE - INTERVAL 90 DAY)
    ) sc
        ON c.customer_id = sc.customer_id
)

SELECT *
FROM churn_data;

