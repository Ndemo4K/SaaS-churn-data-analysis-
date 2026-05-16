# SaaS Customer Churn Analysis

A SQL-based churn analysis project that classifies customers by financial behavior, engagement patterns, and usage trends — producing business-driven insights rather than raw numbers.

**Tech stack:** MySQL 8.0 · SQL CTEs · Google Sheets (reporting)

---

## Business Context

Churn is not simply "customers leaving." It reflects product experience and value perception. This project starts from business hypotheses, not data, and works forward to SQL.

**Hypotheses:**

1. Customers may stop paying due to dissatisfaction or cost concerns
2. Customers may stop engaging because they no longer see value in the product
3. Some customers may still pay but not use the product — a hidden retention opportunity

---

## Churn Personas

Each customer is assigned exactly one label, in priority order:

| Persona | Definition | Business Implication |
|---|---|---|
| **Financial Churn** | No payment in the last 90 days | Highest risk — revenue already lost |
| **Engagement Churn** | No login in the last 90 days | At risk — may cancel soon |
| **Silent Churn** | Still paying but not logging in | Upsell / customer success opportunity |
| **Active** | Paying and logging in regularly | Healthy — focus on retention |

Priority order is intentional: financial loss has the highest business risk and should be acted on first.

---

## Data Model

Four tables drive the analysis. See [`schema.sql`](schema.sql) for full DDL.

| Table | Purpose | Key Columns |
|---|---|---|
| `customers` | Core customer profiles | `customer_id`, `name`, `email`, `signup_date`, `country` |
| `subscriptions` | Subscription lifecycle | `customer_id`, `plan_name`, `start_date`, `end_date`, `status` |
| `transactions` | Billing history | `customer_id`, `transaction_date`, `amount` |
| `user_activity` | Engagement events | `customer_id`, `event_type`, `event_date` |

---

## Analytical Approach

All logic lives in a single query in [`CHURN.sql`](CHURN.sql) using four CTEs:

1. **`financial_churn`** — customers whose `MAX(transaction_date)` is 90+ days ago
2. **`engagement_churn`** — customers whose last `login` event is 90+ days ago
3. **`silent_churn`** — customers with a recent payment but no recent login. `COALESCE` handles customers who have *never* logged in, treating them as silent churners rather than dropping them
4. **Final SELECT** — LEFT JOINs all three CTEs onto the customer base; a `CASE` expression assigns exactly one label per customer

---

## Key Finding

Silent churn returned **zero customers** — and this was investigated rather than ignored.

Every customer who was still paying was also actively logging in. This tells us:

- **Strong product adoption** among paying users — they are getting value
- **No "subscription zombies"** — no one is being charged for a product they forgot about
- The silent churn query is logically correct; the data simply reflects a healthy user base

This is a real insight. Forcing a non-zero result would have been dishonest.

---

## Results

The final classification is exported in [`results of churn analysis.csv`](results%20of%20churn%20analysis.csv).

**Executive Summary (Google Sheets with pivot tables):**
[View Report](https://docs.google.com/spreadsheets/d/1pd0wS7Nqb2vDb96ysfekuvM6FkZSNHOH8OulOsCVWog/edit?usp=sharing)

![Executive Summary](executive%20summary.png)

---

## Skills Demonstrated

- Business problem framing before writing any SQL
- Churn segmentation design with prioritized classification logic
- NULL handling with `COALESCE` to avoid silent data drops
- Honest interpretation — investigating unexpected results rather than ignoring them
- CTE-based query structure for readability and maintainability

---

## Potential Improvements

- Revenue churn (MRR lost, not just customer count)
- Subscription churn vs. behavioral churn comparison
- Cohort-based churn over time (monthly retention curves)
- Customer Lifetime Value integration
