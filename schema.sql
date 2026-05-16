-- ============================================================
-- SaaS Churn Analysis — Database Schema
-- MySQL 8.0
-- ============================================================

CREATE TABLE customers (
    customer_id  INT          PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    email        VARCHAR(150) NOT NULL UNIQUE,
    signup_date  DATE         NOT NULL,
    country      VARCHAR(60)
);

-- Tracks the lifecycle of each subscription (active / expired periods)
CREATE TABLE subscriptions (
    subscription_id INT         PRIMARY KEY,
    customer_id     INT         NOT NULL,
    plan_name       VARCHAR(60),
    start_date      DATE        NOT NULL,
    end_date        DATE,
    status          VARCHAR(20) NOT NULL DEFAULT 'active',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- One row per billing transaction; used to determine last payment date
CREATE TABLE transactions (
    transaction_id   INT            PRIMARY KEY,
    customer_id      INT            NOT NULL,
    transaction_date DATE           NOT NULL,
    amount           DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- One row per user event; event_type = 'login' is used for engagement analysis
CREATE TABLE user_activity (
    activity_id  INT         PRIMARY KEY,
    customer_id  INT         NOT NULL,
    event_type   VARCHAR(50) NOT NULL,
    event_date   DATE        NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
