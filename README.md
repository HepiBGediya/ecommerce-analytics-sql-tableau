**📊 E-Commerce Analytics Project (SQL + Tableau)**

**Project Overview**

This project is a comprehensive E-Commerce Analytics solution built using PostgreSQL (SQL) and Tableau.
It analyzes sales performance, product behavior, returns, and customer value & retention to help business stakeholders make data-driven decisions.

The project follows a real-world analytics workflow:

Raw data → Cleaned data → SQL views (data modeling) → Tableau dashboards → Business insights

**Business Objectives**

The main goals of this project are to:

Track overall sales performance

Identify seasonal revenue trends

Analyze top-performing products

Understand product return behavior

Measure customer value and retention

Apply Pareto (80/20) analysis on products and customers

Support strategic decisions in marketing, inventory, and customer retention

**Dataset Description**

Source: Online Retail Transaction Dataset

Granularity: Order line level

Key Fields:

Invoice No

Invoice Date

Stock Code

Product Description

Quantity

Unit Price

Revenue

Customer ID

Country

Return Flag

The dataset includes completed sales and returns, allowing realistic business analysis.

**Tech Stack**

Database: PostgreSQL

Query Language: SQL

BI Tool: Tableau

Version Control: GitHub

**Data Modeling & SQL Views**

To ensure accuracy and reusability, multiple SQL views were created instead of querying raw data directly.

**Core Helper Views**

vw_orders

One row per invoice

Used for orders, revenue, AOV, and customers

vw_lines

Line-level normalized revenue

Used for product and return analysis

**Fact Views (Key Design Decision)**

**vw_fact_sales**

Purpose: Sales, KPI, time-series, country, and customer analysis

One row per order

Safe for:

Total Revenue

Total Orders

AOV

Monthly & Daily Revenue

Country-level Revenue

Customer analysis

This avoids double counting, a common analytics mistake.

**vw_fact_product**

Purpose: Product performance & return analysis

Includes:

Sold quantity

Returned quantity

SKU revenue

Return rate

Revenue share

Cumulative revenue share (Pareto)

Revenue ranking

This view enables accurate 80/20 analysis and return diagnostics.

**Tableau Dashboards**

**1. Sales Performance Overview**
KPIs

Total Revenue

Total Orders

Average Order Value (AOV)

Total Customers

Charts

Monthly Revenue Trend

Daily Revenue Trend

Country-wise Revenue Map

**Insights**

Strong revenue seasonality with Q4 peak

UK contributes >90% of total revenue

Daily revenue shows high volatility, likely due to promotions

**2. Product Performance & Return Analysis**

Visuals

Top 10 Products by Revenue

Product Pareto (80/20 Rule)

Return Rate by Product

**Insights**

~20% of products generate ~80% of revenue

Few SKUs have abnormally high return rates

High-return products may indicate quality or expectation mismatch

**3. Customer Value & Retention**

Visuals

Top 10 Customers by Revenue

Customer Pareto (80/20 Rule)

Repeat vs One-Time Customers

**Insights**

Revenue is highly concentrated among top customers

Repeat customers dominate revenue contribution

Business growth depends more on retention than acquisition

**Key Business Insights (Summary)**

Revenue is seasonal and concentrated

Small subset of products and customers drive most revenue

Returns are not evenly distributed across products

Retaining high-value customers is critical for long-term growth

**Business Recommendations**

Focus inventory and promotions on top 20% products

Investigate and fix high-return SKUs

Strengthen loyalty programs for repeat customers

Reduce dependency on a single geography by exploring new markets

Use daily revenue volatility to optimize campaign timing

**Project Structure**

ecommerce-project/

│

├── data/            # Raw / cleaned dataset

├── sql/             # SQL scripts & views

├── tableau/         # Tableau workbook

├── reports/         # Dashboard screenshots

└── README.md        # Project documentation

**Outcome**

This project demonstrates:

Strong SQL data modeling

Correct KPI logic

Professional Tableau dashboard design

Clear business storytelling

Real-world analytics thinking
