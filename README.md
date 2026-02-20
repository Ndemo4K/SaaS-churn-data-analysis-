 Customer Churn Analysis — SQL SaaS Analytics Project
 Overview

This project performs Customer Churn Analysis using pure SQL (MySQL 8.0.44).
It classifies customers based on financial behavior, engagement patterns, and usage trends — providing business-driven insights rather than just numbers.

The objective is to:

Understand why customers churn

Identify who is at risk

Support data-driven retention strategies

1. Business Context

Churn is not simply “customers leaving.”
It reflects behavior and product experience. Before coding, this project establishes realistic churn scenarios:

2.Hypotheses

1️⃣ Customers may stop paying due to dissatisfaction or cost concerns
2️⃣ Customers may stop engaging because they no longer see value
3️⃣ Some customers may still pay but not use the product (important business opportunity)

These translate into four customer personas.

👥 Churn Personas Defined
Persona	Description
Financial Churn	Customer hasn’t made a payment in 90+ days
Engagement Churn	Customer hasn’t logged in for 90+ days
Silent Churn	Customer is still paying but not logging in
Healthy Customer	Customer is paying and actively using the platform

Each persona reveals different product and business implications.

🗂️ Data Sources

This project uses four key tables:

customers

Basic user profile information
customer_id, name, email, signup_date, country

subscriptions

Subscription lifecycle tracking (active/expired periods)

transactions

Tracks spending history
Used to determine last payment

user_activity

Tracks engagement behavior
Used to determine last login

🧠 Analytical Approach
1️⃣ Financial Churn

Identify customers whose last transaction date ≥ 90 days ago

2️⃣ Engagement Churn

Identify users whose last login ≥ 90 days ago

3️⃣ Silent Churn

Identify users who:

Still have transactions in the last 90 days

BUT have not logged in in 90+ days

OR have no login history at all

4️⃣ Final Classification

Combine all churn definitions using CTEs + LEFT JOINS.
Priority order is intentional:

Financial → Engagement → Silent → Active


because financial loss has the highest business risk.

✅ Key Outcome

Final dataset outputs:

customer_id	name	email	churn_type

Each customer is assigned exactly one churn category.

🔍 Key Finding

During analysis:

Financial churn existed

Engagement churn existed

Silent churn returned zero customers

This was investigated — not ignored.

It revealed:

All customers who were still paying were also logging in.

This indicates:

Strong product adoption among paying users

No unnoticed “subscription zombies”

No artificial churn inflation

This is a real insight, not a failure of the query.

⚙️ Tech Stack

MySQL 8.0.44

SQL CTEs, joins, grouping, date filtering

Exported to Google Sheets for review

📈 Skills Demonstrated

Business problem framing

SQL data modeling & reasoning

Null handling & logical prioritization

Churn analytics understanding

Interpreting data honestly instead of forcing outcomes

🚀 Future Improvements

Potential enhancements:

Revenue churn metrics

Subscription churn vs behavioral churn comparison

Cohort churn over time

Customer Lifetime Value integration




Here is the executive summary for the analysis:https://docs.google.com/spreadsheets/d/1pd0wS7Nqb2vDb96ysfekuvM6FkZSNHOH8OulOsCVWog/edit?usp=sharing

🙌 Why This Project Matters


This project shows more than SQL ability — it demonstrates analytical thinking, business understanding, debugging skill, and integrity in results.
 pivot table :https://docs.google.com/spreadsheets/d/e/2PACX-1vRDt2TrD9EpYMcQmuU-xRB19UmCy84q5B528g5etyE7_jjKWM-wtCcdpb-81bnAVddmeuK9F2JU3dvq/pub?gid=326180473&single=true&output=csv
