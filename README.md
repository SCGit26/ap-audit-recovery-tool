# Automated AP Duplicate Payment & Audit Recovery Pipeline

## Project Overview

In enterprise Procure-to-Pay (PTP) operations, manual Accounts Payable (AP) reviews frequently miss disguised duplicate billings, split-requisition threshold bypasses, and vendor tax overcharges—resulting in direct cash leakage.

This project implements an end-to-end **AP Audit Recovery Pipeline** using **PostgreSQL** and **Python (`pandas`, `psycopg2`)**. It pairs relational database modeling and standalone SQL audit rules with a Python automation engine that flags high-risk payment anomalies and exports an executive recovery report (`ap_audit_summary.csv`) for AP and Finance leadership.

## Business Objectives & Controls Implemented

* **Exact Duplicate Payment Detection:** Identifies multiple invoices billed by the same vendor for identical dollar amounts to prevent double disbursements.
* **Split-Requisition Threshold Auditing:** Flags multiple invoices issued by the same vendor on the same day structured just below standard managerial approval limits.
* **Tax & Freight Overpayment Auditing:** Identifies invoices where billed tax is more than `15%` or freight charges exceed expected thresholds to catch vendor billing errors prior to settlement.
* **Automated Exception Reporting:** Eliminates manual spreadsheet auditing by programmatically generating a clean CSV recovery log ready for vendor credit memos or payment holds.

## Tech Stack & Architecture

* **Database & SQL Analytics:** PostgreSQL (`ap.ap_audit_transactions`)
* **Automation & Data Processing:** Python 3, `pandas`, `psycopg2-binary`
* **Output:** Automated console summary & CSV recovery report (`ap_audit_summary.csv`)

### Repository Structure

```text
├── sql/
│   ├── 01_create_schema.sql          # PostgreSQL table schema & indexing setup
│   ├── 02_audit_data.sql             # Baseline AP dataset + planted anomaly scenarios
│   └── 03_audit_detection_rules.sql  # Standalone SQL anomaly detection & verification queries
├── audit_pipeline.py                 # Python ETL & automated audit rules engine
├── ap_audit_summary.csv              # Generated audit exception & cash-at-risk report
└── README.md                         # Project documentation
```

## How to Run Locally

### 1. Database Setup & SQL Verification (PostgreSQL)

Execute the SQL scripts in sequential order inside your target PostgreSQL database to build the schema, load the test dataset, and preview the standalone SQL detection rules:

```sql
-- Step 1: Create the ap.ap_audit_transactions table
\i sql/01_create_table.sql

-- Step 2: Populate sample baseline & anomaly records
\i sql/02_audit_data.sql

-- Step 3 (Optional): Run standalone SQL audit queries
\i sql/03_audit_detection_rules.sql
```

### 2. Install Python Dependencies

Ensure `pandas` and `psycopg2-binary` are installed in your local Python environment:

```bash
pip install pandas psycopg2-binary
```

### 3. Configure Database Credentials & Execute Pipeline

Update `DB_CONFIG` in `audit_pipeline.py` (or set your `PGPASSWORD` environment variable) and run the automated Python pipeline:

```bash
set PGPASSWORD=your_postgres_password
python audit_pipeline.py
```

## Sample Output & Business Impact

When executed against the test dataset (`17` AP transactions), the pipeline automatically surfaces planted leakage vectors and outputs a structured exception log:

| Rule Triggered | Invoice ID | Vendor | Amount at Risk | Audit Note |
| :--- | :--- | :--- | :--- | :--- |
| **Exact Duplicate Payment** | `INV-1006` | Midwest Logistics Group | `$8,420.00` | Matched vendor and amount (`$8,420.00`) |
| **Exact Duplicate Payment** | `INV-1006-DUP` | Midwest Logistics Group | `$8,420.00` | Matched vendor and amount (`$8,420.00`) |
| **Exact Duplicate Payment** | `INV-2044` | Apex Cloud Solutions | `$19,750.00` | Matched vendor and amount (`$19,750.00`) |
| **Exact Duplicate Payment** | `INV-2044A` | Apex Cloud Solutions Inc. | `$19,750.00` | Matched vendor and amount (`$19,750.00`) |
| **Tax Overpayment Anomaly** | `INV-4001` | Global Office Supply Co | `$768.00` | Tax amount is unusually high relative to invoice total |