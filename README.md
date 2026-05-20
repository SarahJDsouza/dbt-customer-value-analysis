# 🌸 Who Are Our Most Valuable Customers?
### A dbt + BigQuery Analysis | Jaffle Shop Dataset | Q3 2016

![dbt](https://img.shields.io/badge/dbt-1.11.9-orange?style=flat-square&logo=dbt)
![BigQuery](https://img.shields.io/badge/BigQuery-Google%20Cloud-blue?style=flat-square&logo=google-cloud)
![Tests](https://img.shields.io/badge/tests-18%20passing-brightgreen?style=flat-square)
![Models](https://img.shields.io/badge/models-3-teal?style=flat-square)

---

## 📌 Analytics Question

> **"Who are our most valuable customers — and how do we define value?"**

This project uses dbt and BigQuery to answer this question by building a customer lifetime value model from raw transactional data. Customers are segmented by loyalty and ranked using a weighted score that rewards both high spend and consistent return visits.

---

## 🗂️ Project Structure

```
university_workshop_starter_dbt/
│
├── models/
│   ├── staging/
│   │   ├── _sources.yml          ← source definitions
│   │   ├── stg_customers.sql     ← clean raw_customers
│   │   └── stg_orders.sql        ← clean raw_orders
│   │
│   └── marts/
│       ├── customer_lifetime_value.sql   ← core business model
│       └── customer_lifetime_value.yml   ← docs + tests
│
├── tests/
│   ├── assert_lifetime_value_gte_average_order_value.sql
│   ├── assert_customer_rank_is_positive.sql
│   ├── assert_days_as_customer_not_negative.sql
│   └── assert_total_orders_positive.sql
│
├── seeds/                        ← raw CSV files
├── dbt_project.yml
└── README.md
```

---

## 🏗️ Model Flow

```
raw_customers (BigQuery)          raw_orders (BigQuery)
      │                                  │
      ▼                                  ▼
stg_customers                      stg_orders
(rename + clean)                  (rename + clean)
      │                                  │
      └──────────────┬───────────────────┘
                     ▼
          customer_lifetime_value
          ┌─────────────────────────────────┐
          │ customer_id + customer_name      │
          │ total_orders                     │
          │ average_order_value              │
          │ customer_value                   │
          │ customer_lifetime_value          │
          │ customer_segment                 │
          │ weighted_score                   │
          │ customer_rank (within segment)   │
          │ days_as_customer                 │
          │ first_order_date                 │
          │ most_recent_order_date           │
          └─────────────────────────────────┘
```

---

## 📊 Data Sources

| Table | Rows | Description |
|-------|------|-------------|
| `raw_customers` | 128 | Unique customers with id and name |
| `raw_orders` | ~500+ | Orders placed Sep 1–16, 2016 with order totals |

Both tables were loaded from Google Cloud Storage into BigQuery using the `bq load` CLI.

---

## 🧮 How We Define Customer Value

A valuable customer must score well on **all three dimensions**:

| Parameter | Formula | What it captures |
|-----------|---------|-----------------|
| `customer_value` | `avg_order_value × total_orders` | How much they spend in total |
| `total_orders` | `count(order_id)` | How often they come back |
| `days_as_customer` | `last_order_date - first_order_date` | How long they stay |

**Final ranking formula:**
```
weighted_score = customer_value × total_orders × days_as_customer
```

---

## 👥 Customer Segmentation

Customers are segmented by `days_as_customer` before ranking:

| Segment | Days | Customers | % |
|---------|------|-----------|---|
| 🟠 Occasional | 0–4 days | 16 | 13% |
| 🔵 Returning | 5–10 days | 31 | 24% |
| 🟢 Loyal | 11–15 days | 81 | 63% |

> Rankings are calculated **within each segment** using `rank() over (partition by customer_segment order by weighted_score desc)`

---

## 🏆 Top Results

| Rank | Customer | Segment | Orders | Weighted Score |
|------|----------|---------|--------|---------------|
| #1 🏆 | Brenda Miller | LOYAL | 9 | 1,500,525 |
| #2 | Douglas Hill | LOYAL | 6 | 1,305,000 |
| #3 | Pamela Lane | LOYAL | 8 | 1,139,600 |
| #1 ⚡ | Ryan Byrd | OCCASIONAL | 2 | 111,294 |
| #1 📈 | Jeffrey Love | RETURNING | 4 | 450,606 |

---

## ✅ Testing

18 total checks passing across 3 models.

### yml Tests (10)
| Column | Test | Purpose |
|--------|------|---------|
| `customer_id` | `unique` | Primary key — no duplicates |
| `customer_id` | `not_null` | Primary key — no blanks |
| `customer_name` | `not_null` | Every customer has a name |
| `customer_segment` | `accepted_values` | Only valid segment labels |
| All columns | `not_null` | No missing values |

### Business Logic Assert Tests (4)

| Test | What it checks |
|------|---------------|
| `assert_lifetime_value_gte_average_order_value` | `customer_value >= average_order_value` always |
| `assert_customer_rank_is_positive` | Rank is always > 0 |
| `assert_days_as_customer_not_negative` | Last order never before first order |
| `assert_total_orders_positive` | Every customer has at least 1 order |

Run all tests:
```bash
dbtf build --select stg_customers stg_orders customer_lifetime_value
# Result: 18 total | 18 success ✓
```

---

## 💡 Key Insights

1. **63% of customers are loyal** — strong initial retention within a 15-day window
2. **Frequency + loyalty beats pure spend** — Brenda Miller outranks Douglas Hill despite lower avg order value
3. **Ryan Byrd is highest risk/reward** — spent $18,549 in 6 days; one return visit makes him #1 overall
4. **31 returning customers are the growth opportunity** — one purchase away from loyal status
5. **CLV is unreliable with short-window data** — weighted score is the more meaningful metric here

---

## 🚀 Actionable Next Steps

| Priority | Action | Target |
|----------|--------|--------|
| 🟢 High | VIP loyalty program | Customers with `weighted_score > 1,000,000` |
| 🔵 High | Re-engagement campaign | 31 returning customers within 5 days |
| 🟠 Medium | Personal outreach | Ryan Byrd — immediate contact |

---

## ⚙️ Setup & Running

### Prerequisites
- Python 3.12+
- dbt-fusion (`dbtf`) or dbt-core
- Google Cloud SDK (`gcloud`)
- BigQuery project with billing enabled

### Installation

```bash
# Clone the repo
git clone https://github.com/SarahJDsouza/university_workshop_starter_dbt.git
cd university_workshop_starter_dbt

# Install dbt packages
dbt deps

# Set up your profile
dbtf init
# Choose: BigQuery → your project ID → dbt_<yourname> dataset → US region → auth method
```

### Running the project

```bash
# Debug connection
dbtf debug

# Build all models + run all tests
dbtf build --select stg_customers stg_orders customer_lifetime_value

# Compile only
dbtf compile

# Run tests only
dbtf test --select customer_lifetime_value
```

### Loading raw data into BigQuery

```powershell
# PowerShell — load CSVs from GCS into BigQuery raw dataset
$BUCKET = "gs://moms-flower-shop-data"
$uris = gcloud storage ls "$BUCKET/*.csv"

foreach ($uri in $uris) {
    $table = (Split-Path $uri -Leaf).Replace(".csv", "").Replace("-", "_")
    bq load `
        --project_id=your-project-id `
        --autodetect `
        --skip_leading_rows=1 `
        --source_format=CSV `
        "your-project-id:raw.$table" `
        "$uri"
}
```

---

## 📁 Fact vs Dimension Tables

This project follows the **star schema** pattern:

| Table | Type | Description |
|-------|------|-------------|
| `raw_orders` | **Fact** | Records what happened — each row is one transaction |
| `raw_customers` | **Dimension** | Describes who — each row is one customer |

The mart model aggregates the fact table and joins the dimension table — the classic star schema pattern.

---

## 👩‍💻 Author

**Sarah D'souza**
Built as part of the dbt University Workshop — May 2026

---

## 📄 License

This project is based on the [dbt Labs university workshop starter](https://github.com/atrivedi-dbtlabs/university_workshop_starter) repository.
