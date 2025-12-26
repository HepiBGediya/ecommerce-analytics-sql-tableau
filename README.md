# E-Commerce Analytics Project (SQL + Tableau)

## Project Overview

This project is a comprehensive **end-to-end E-Commerce Analytics solution** built using **PostgreSQL (SQL)** and **Tableau**.  
It analyzes **sales performance, product behavior, returns, and customer value & retention** to help business stakeholders make **data-driven decisions**.

The project follows a real-world analytics workflow:

**Raw Data → Cleaned Data → SQL Views (Data Modeling) → Tableau Dashboards → Business Insights**

---

## Business Objectives

The primary goals of this project are to:

- Track overall sales performance and key KPIs  
- Identify seasonal and daily revenue trends  
- Analyze top-performing products  
- Understand product return behavior  
- Measure customer value and retention  
- Apply **Pareto (80/20) analysis** on products and customers  
- Support strategic decisions in **marketing, inventory, and customer retention**

---

## Dataset Description

- **Source:** Online Retail Transaction Dataset (public dataset)  
- **Granularity:** Order line level  

### Key Fields
- Invoice No  
- Invoice Date  
- Stock Code  
- Product Description  
- Quantity  
- Unit Price  
- Revenue  
- Customer ID  
- Country  
- Return Flag  

The dataset includes both **completed sales and returns**, enabling realistic and business-relevant analysis.

---

## Tech Stack

- **Database:** PostgreSQL  
- **Query Language:** SQL  
- **BI Tool:** Tableau  
- **Version Control:** GitHub  

---

## Data Modeling & SQL Views

To ensure **KPI accuracy, scalability, and reusability**, analysis is performed using **SQL views** instead of querying raw data directly.

### Core Helper Views

- **vw_orders**
  - One row per invoice  
  - Used for orders, revenue, AOV, and customer analysis  

- **vw_lines**
  - Line-level normalized revenue  
  - Used for product and return analysis  

---

## Fact Views (Key Design Decision)

### vw_fact_sales

**Purpose:** Sales KPIs, time-series, geography, and customer analysis  

- One row per order  
- Safe for:
  - Total Revenue  
  - Total Orders  
  - Average Order Value (AOV)  
  - Monthly & Daily Revenue  
  - Country-level Revenue  
  - Customer metrics  

This design avoids **double counting**, a common analytics mistake when working with transactional data.

---

### vw_fact_product

**Purpose:** Product performance and return analysis  

Includes:
- Sold quantity  
- Returned quantity  
- SKU revenue  
- Return rate  
- Revenue share  
- Cumulative revenue share (Pareto)  
- Revenue ranking  

This view enables **accurate 80/20 analysis** and **return diagnostics**.

---

## Tableau Dashboards

### 1. Sales Performance Overview

**KPIs**
- Total Revenue  
- Total Orders  
- Average Order Value (AOV)  
- Total Customers  

**Visuals**
- Monthly Revenue Trend  
- Daily Revenue Trend  
- Country-wise Revenue Map  

**Insights**
- Strong revenue seasonality with a Q4 peak  
- UK contributes over 90% of total revenue  
- Daily revenue shows high volatility, likely driven by promotions  

---

### 2. Product Performance & Return Analysis

**Visuals**
- Top 10 Products by Revenue  
- Product Pareto (80/20 Rule)  
- Return Rate by Product  

**Insights**
- ~20% of products generate ~80% of total revenue  
- A small number of SKUs have abnormally high return rates  
- High-return products may indicate quality or expectation mismatch  

---

### 3. Customer Value & Retention

**Visuals**
- Top 10 Customers by Revenue  
- Customer Pareto (80/20 Rule)  
- Repeat vs One-Time Customers  

**Insights**
- Revenue is highly concentrated among top customers  
- Repeat customers dominate revenue contribution  
- Business growth depends more on **retention** than acquisition  

---

## Key Business Insights

- Revenue shows strong seasonality with a peak in Q4  
- UK contributes the majority of total revenue  
- Top ~20% of products generate ~80% of revenue (Pareto principle)  
- High return rates are concentrated in a small subset of products  
- Repeat customers drive a significant share of overall revenue  

---

## Business Recommendations

- Focus inventory and promotions on the top 20% of products  
- Investigate and fix high-return SKUs (quality, packaging, or expectations)  
- Strengthen loyalty programs to retain high-value repeat customers  
- Reduce dependency on a single geography by exploring new markets  
- Use daily revenue volatility insights to optimize campaign timing  

---

## Dashboards

Screenshots of all Tableau dashboards are available in the `reports/` folder.

---

## Outcome

This project demonstrates the ability to deliver a **complete, real-world E-Commerce analytics solution** from raw data to business-ready insights.

Through this project, I successfully:

- Designed **accurate SQL data models** using fact and helper views to prevent double counting  
- Built **reliable KPIs** for revenue, orders, AOV, customers, products, and returns  
- Applied **Pareto (80/20) analysis** to both products and customers  
- Analyzed **return behavior** to identify high-risk SKUs  
- Created **professional, executive-ready Tableau dashboards**  
- Translated analytical results into **clear business insights and recommendations**  

## Project Structure

```text
ecommerce-analytics-sql-tableau/
│
├── data/            # Raw and processed datasets
├── notebooks/       # Data inspection, cleaning, and EDA notebooks
├── sql/             # SQL scripts and analytical views
├── tableau/         # Tableau workbook
├── reports/         # Dashboard screenshots
└── README.md        # Project documentation
