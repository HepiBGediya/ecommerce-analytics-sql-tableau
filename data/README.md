This folder contains all datasets used in the E-Commerce Analytics project.

---

## 📂 raw/

### Description
Contains the original, unmodified dataset downloaded from an online public source.

### Files
- `Online Retail.xlsx`

### Notes
- This data is kept **unchanged** to preserve data lineage
- All cleaning and transformations are done in notebooks
- Raw data is never edited directly

---

## 📂 processed/

### Description
Contains cleaned and aggregated datasets generated during analysis.

### Files
- `online_retail_clean_step1.csv` – basic cleaning (I cannot upload it in this as it's a big file but I have that file.)
- `online_retail_clean_final.csv` – final cleaned dataset (I cannot upload it in this as it's a big file but I have that file.)
- `monthly_revenue.csv`
- `returns_by_month.csv`
- `returns_by_product.csv`
- `sku_pareto.csv`
- `top_products.csv`
- `top_customers.csv`
- `rfm_customers.csv`

### Usage
These files are used for:
- SQL data modeling (PostgreSQL)
- Tableau dashboards
- KPI calculations
