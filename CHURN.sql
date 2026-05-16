-- ============================================================
-- SaaS Customer Churn Analysis
-- MySQL 8.0 | Author: Ndemo4K
-- ============================================================
-- Business goal: classify every customer into exactly one
-- churn category so retention teams can prioritize outreach.
--
-- Churn personas (in priority order):
--   1. Financial Churn  — no payment in the last 90 days
--   2. Engagement Churn — no login in the last 90 days
--   3. Silent Churn     — still paying but not logging in
--   4. Active           — paying and logging in regularly
-- ============================================================

WITH

-- Customers whose last transaction was 90+ days ago
financial_churn AS (
    SELECT customer_id
    FROM transactions
    GROUP BY customer_id
    HAVING MAX(transaction_date) < (CURRENT_DATE - INTERVAL 90 DAY)
),

-- Customers whose last login was 90+ days ago
engagement_churn AS (
    SELECT customer_id
    FROM user_activity
    WHERE event_type = 'login'
    GROUP BY customer_id
    HAVING MAX(event_date) < (CURRENT_DATE - INTERVAL 90 DAY)
),

-- Customers who are still paying but have stopped logging in.
-- COALESCE handles customers who have never logged in at all —
-- they are treated as if their last login was in the distant past.
silent_churn AS (
    SELECT t.customer_id
    FROM transactions t
    LEFT JOIN user_activity ua
        ON t.customer_id = ua.customer_id
       AND ua.event_type = 'login'
    GROUP BY t.customer_id
    HAVING
        MAX(t.transaction_date) >= (CURRENT_DATE - INTERVAL 90 DAY)
        AND COALESCE(MAX(ua.event_date), '1900-01-01') < (CURRENT_DATE - INTERVAL 90 DAY)
)

-- Final classification: each customer gets exactly one label.
-- Priority order matters — financial loss carries the highest business risk.
SELECT
    c.customer_id,
    c.name,
    c.email,
    CASE
        WHEN fc.customer_id IS NOT NULL THEN 'Financial Churn'
        WHEN ec.customer_id IS NOT NULL THEN 'Engagement Churn'
        WHEN sc.customer_id IS NOT NULL THEN 'Silent Churn'
        ELSE 'Active'
    END AS churn_type
FROM customers c
LEFT JOIN financial_churn  fc ON c.customer_id = fc.customer_id
LEFT JOIN engagement_churn ec ON c.customer_id = ec.customer_id
LEFT JOIN silent_churn     sc ON c.customer_id = sc.customer_id
ORDER BY churn_type, c.customer_id;
