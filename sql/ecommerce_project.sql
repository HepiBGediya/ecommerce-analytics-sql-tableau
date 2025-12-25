CREATE TABLE online_retail (
    InvoiceNo VARCHAR,
    StockCode VARCHAR,
    Description TEXT,
    Quantity INT,
    InvoiceDate TIMESTAMP,
    UnitPrice NUMERIC,
    CustomerID VARCHAR,
    Country VARCHAR,
    IsReturn BOOLEAN,
    Revenue NUMERIC
);

-- STEP 1: Load clean data into SQL

-- STEP 2: Validate your SQL table
SELECT COUNT(*) FROM online_retail;
SELECT * FROM online_retail LIMIT 10;

-- STEP 3: Recreate core business metrics inside SQL

-- 1. Total Revenue
SELECT SUM(revenue) AS total_revenue
FROM online_retail
WHERE isreturn = false;

-- 2. Number of Orders
SELECT COUNT(DISTINCT invoiceno) AS total_orders
FROM online_retail
WHERE isreturn = false;

-- 3. Unique Customers
SELECT COUNT(DISTINCT customerid) AS total_customers
FROM online_retail;

-- 4. AOV (Average Order Value)
SELECT AVG(order_value) AS aov
FROM (
  SELECT invoiceno, SUM(quantity * unitprice) AS order_value
  FROM online_retail
  WHERE isreturn = false
  GROUP BY invoiceno
) t;

-- STEP 4: Time-Based Analysis

-- 1. Monthly Revenue
SELECT DATE_TRUNC('month', invoicedate) AS month,
       SUM(revenue) AS revenue
FROM online_retail
WHERE isreturn = false
GROUP BY 1
ORDER BY 1;

-- 2. Daily Trend 
SELECT
  invoicedate::date AS day,
  SUM(quantity * unitprice) AS revenue
FROM online_retail
WHERE isreturn = false
GROUP BY 1
ORDER BY 1;

-- STEP 5: Product Analysis Metrics

-- 1. Top 10 Products by Revenue
SELECT description, SUM(revenue) AS revenue
FROM online_retail
WHERE isreturn = false
GROUP BY description
ORDER BY revenue DESC
LIMIT 10;

-- 2. Pareto (80/20 rule base)
SELECT 
    description,
    SUM(quantity * unitprice) AS revenue
FROM online_retail
WHERE isreturn = false
GROUP BY description
ORDER BY revenue DESC;

-- STEP 6: Customer Analysis Metrics

-- 1. Repeat Customer Rate
SELECT 
    SUM(CASE WHEN order_count > 1 THEN 1 END) * 1.0 /
    COUNT(*) AS repeat_rate
FROM (
     SELECT customerid, COUNT(DISTINCT invoiceno) AS order_count
     FROM online_retail
     GROUP BY customerid
) t;

-- 2. Customer lifetime value (CLV basics)
SELECT 
  customerid,
  SUM(quantity * unitprice) AS lifetime_value
FROM online_retail
WHERE isreturn = false
GROUP BY customerid
ORDER BY lifetime_value DESC;

-- STEP 7: Country-Level Revenue

SELECT country, SUM(quantity * unitprice) AS total_revenue
FROM online_retail
WHERE isreturn = false
GROUP BY country
ORDER BY total_revenue DESC;

-- STEP 8: Views

-- 1. Base helpers — orders and line revenue

-- A. Orders (one row per invoice, with invoice-level revenue and customer)
CREATE OR REPLACE VIEW public.vw_orders AS
SELECT
  lower(trim(invoiceno))                 AS invoice_no,
  MIN(invoicedate)                       AS invoice_date,
  COUNT(*)                               AS line_count,
  SUM(COALESCE(revenue, quantity * unitprice)) AS invoice_revenue,
  MIN(customerid)                        AS customer_id
FROM public.online_retail
GROUP BY lower(trim(invoiceno));

-- B. Line-level revenue normalized (useful for product metrics)
CREATE OR REPLACE VIEW public.vw_lines AS
SELECT
  lower(trim(invoiceno))                 AS invoice_no,
  stockcode,
  description,
  quantity,
  unitprice,
  COALESCE(revenue, quantity * unitprice) AS line_revenue,
  invoicedate,
  customerid,
  country,
  isreturn
FROM public.online_retail;

-- 2. Sales overview — monthly & daily revenue

-- A. Monthly Revenue (calendar month)
CREATE OR REPLACE VIEW public.vw_monthly_revenue AS
SELECT
  date_trunc('month', invoicedate)::date AS month,
  SUM(COALESCE(revenue, quantity * unitprice)) FILTER (WHERE isreturn = false) AS revenue,
  SUM(COALESCE(revenue, quantity * unitprice)) FILTER (WHERE isreturn = true)  AS returns
FROM public.online_retail
GROUP BY 1
ORDER BY 1;

-- B. Daily Revenue (calendar day)
CREATE OR REPLACE VIEW public.vw_daily_revenue AS
SELECT
  date_trunc('day', invoicedate)::date AS day,
  SUM(COALESCE(revenue, quantity * unitprice)) FILTER (WHERE isreturn = false) AS revenue
FROM public.online_retail
GROUP BY 1
ORDER BY 1;

-- 3. Product analysis — top products and quantity

-- A. Top products by revenue (all time)
CREATE OR REPLACE VIEW public.vw_top_products_revenue AS
SELECT
  description,
  stockcode,
  SUM(COALESCE(revenue, quantity * unitprice)) FILTER (WHERE isreturn = false) AS revenue,
  SUM(quantity) FILTER (WHERE isreturn = false) AS qty_sold
FROM public.online_retail
GROUP BY description, stockcode
ORDER BY revenue DESC;

-- B. Top products by quantity
CREATE OR REPLACE VIEW public.vw_top_products_qty AS
SELECT
  description,
  stockcode,
  SUM(quantity) FILTER (WHERE isreturn = false) AS qty_sold,
  SUM(COALESCE(revenue, quantity * unitprice)) FILTER (WHERE isreturn = false) AS revenue
FROM public.online_retail
GROUP BY description, stockcode
ORDER BY qty_sold DESC;

-- 4. Pareto (SKU cumulative revenue share)

-- SKU Pareto: revenue share cumulative (useful to plot cumulative share)
CREATE OR REPLACE VIEW public.vw_sku_pareto AS
WITH sku AS (
  SELECT
    stockcode,
    description,
    SUM(COALESCE(revenue, quantity * unitprice)) FILTER (WHERE isreturn = false) AS sku_revenue
  FROM public.online_retail
  GROUP BY stockcode, description
)
SELECT
  stockcode,
  description,
  sku_revenue,
  sku_revenue / SUM(sku_revenue) OVER () AS revenue_share,
  SUM(sku_revenue) OVER (ORDER BY sku_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    / SUM(sku_revenue) OVER () AS cumulative_share,
  ROW_NUMBER() OVER (ORDER BY sku_revenue DESC) AS rank
FROM sku
ORDER BY sku_revenue DESC;

-- 5. Return rates by product

CREATE OR REPLACE VIEW public.vw_return_rate_by_product AS
SELECT
  stockcode,
  description,
  SUM(quantity) FILTER (WHERE isreturn = false) AS sold_qty,
  SUM(quantity) FILTER (WHERE isreturn = true)  AS returned_qty,
  CASE WHEN SUM(quantity) FILTER (WHERE isreturn = false) = 0 THEN 0
       ELSE SUM(quantity) FILTER (WHERE isreturn = true)::numeric
            / NULLIF(SUM(quantity) FILTER (WHERE isreturn = false), 0)
  END AS return_rate
FROM public.online_retail
GROUP BY stockcode, description
ORDER BY return_rate DESC NULLS LAST;

-- 6. Country-level revenue (for your map / table)

CREATE OR REPLACE VIEW public.vw_country_revenue AS
SELECT
  country,
  SUM(COALESCE(revenue, quantity * unitprice)) FILTER (WHERE isreturn = false) AS total_revenue,
  SUM(COALESCE(revenue, quantity * unitprice)) FILTER (WHERE isreturn = true)  AS return_amount,
  COUNT(DISTINCT customerid) AS unique_customers
FROM public.online_retail
GROUP BY country
ORDER BY total_revenue DESC;

-- 7. Customer / Orders metrics — AOV, repeat rate, CLV starter

-- Average Order Value (AOV)
CREATE OR REPLACE VIEW public.vw_aov AS
SELECT
  AVG(invoice_revenue) AS aov
FROM public.vw_orders
WHERE invoice_revenue IS NOT NULL;

-- Repeat customer vs one-time customers (by customer)
CREATE OR REPLACE VIEW public.vw_customer_orders AS
SELECT
  customerid,
  COUNT(DISTINCT lower(trim(invoiceno))) AS orders_count,
  SUM(COALESCE(revenue, quantity * unitprice)) FILTER (WHERE isreturn = false) AS customer_revenue
FROM public.online_retail
GROUP BY customerid;

CREATE OR REPLACE VIEW public.vw_repeat_rate AS
SELECT
  SUM(CASE WHEN orders_count > 1 THEN 1 ELSE 0 END)::numeric / COUNT(*) AS repeat_rate,
  COUNT(*) FILTER (WHERE orders_count = 1) AS one_time_customers,
  COUNT(*) FILTER (WHERE orders_count > 1) AS repeat_customers,
  AVG(customer_revenue) AS avg_customer_value
FROM public.vw_customer_orders;

-- Simple CLV (historical revenue per customer). For real CLV you'd use recency/ltv model.
CREATE OR REPLACE VIEW public.vw_customer_lifetime AS
SELECT
  customerid,
  SUM(COALESCE(revenue, quantity * unitprice)) FILTER (WHERE isreturn = false) AS lifetime_revenue,
  COUNT(DISTINCT lower(trim(invoiceno))) AS lifetime_orders,
  SUM(quantity) FILTER (WHERE isreturn = false) AS lifetime_qty
FROM public.online_retail
GROUP BY customerid;

DROP VIEW IF EXISTS public.vw_fact_product;

CREATE VIEW public.vw_fact_product AS
WITH base AS (
    SELECT
        stockcode,
        description,

        -- quantities
        SUM(quantity) FILTER (WHERE isreturn = false) AS sold_qty,
        SUM(quantity) FILTER (WHERE isreturn = true)  AS returned_qty,

        -- revenue (exclude returns)
        SUM(COALESCE(revenue, quantity * unitprice))
            FILTER (WHERE isreturn = false) AS sku_revenue
    FROM public.online_retail
    GROUP BY stockcode, description
),

metrics AS (
    SELECT
        *,
        CASE
            WHEN sold_qty = 0 THEN 0
            ELSE returned_qty::NUMERIC / sold_qty
        END AS return_rate
    FROM base
),

pareto AS (
    SELECT
        *,
        sku_revenue / SUM(sku_revenue) OVER () AS revenue_share,
        SUM(sku_revenue) OVER (
            ORDER BY sku_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(sku_revenue) OVER () AS cumulative_revenue_share,
        ROW_NUMBER() OVER (ORDER BY sku_revenue DESC) AS revenue_rank
    FROM metrics
)

SELECT
    stockcode,
    description,
    sku_revenue,
    sold_qty,
    returned_qty,
    return_rate,
    revenue_share,
    cumulative_revenue_share,
    revenue_rank
FROM pareto;

DROP VIEW IF EXISTS public.vw_fact_sales;

CREATE OR REPLACE VIEW public.vw_fact_sales AS
SELECT
    o.invoice_no,
    o.invoice_date,
    DATE_TRUNC('month', o.invoice_date)::date AS invoice_month,

    o.customer_id,
    c.country,

    -- Core KPIs (SAFE)
    o.invoice_revenue        AS order_revenue,
    1                        AS order_count,

    -- AOV-safe (per order)
    o.invoice_revenue        AS aov_base

FROM public.vw_orders o
LEFT JOIN (
    SELECT
        lower(trim(invoiceno)) AS invoice_no,
        MIN(country)           AS country
    FROM public.online_retail
    WHERE customerid IS NOT NULL
    GROUP BY lower(trim(invoiceno))
) c
ON o.invoice_no = c.invoice_no

WHERE o.invoice_revenue IS NOT NULL;
