"""
Project 3: Automated AP Audit Recovery Pipeline
Description: Connects to PostgreSQL, finds duplicate payments and tax overpayments 
             using clean Pandas methods, and exports an audit summary.
"""

import os
import pandas as pd
import psycopg2

# 1. Database Connection Settings
DB_CONFIG = {
    "host": "localhost",
    "port": "5432",
    "database": "procurement_analytics",
    "user": "postgres",
    "password": os.getenv("PGPASSWORD", "your_password_here"),
}

def run_simple_audit():
    print("--- Starting AP Audit Recovery Pipeline ---")
    
    # Connect to database and load data into a Pandas DataFrame
    conn = psycopg2.connect(**DB_CONFIG)
    query = "SELECT invoice_id, vendor_id, vendor_name, invoice_date, invoice_amount::FLOAT, tax_amount::FLOAT, department FROM public.ap_audit_transactions;"
    df = pd.read_sql_query(query, conn)
    conn.close()
    
    print(f"Loaded {len(df)} total transactions from PostgreSQL.\n")
    
    findings = []
    
    # ----------------------------------------------------
    # RULE 1: Find Exact Duplicate Payments 
    # (Same Vendor + Same Amount)
    # ----------------------------------------------------
    # Pandas .duplicated() flags rows that share the exact same vendor and amount
    duplicate_mask = df.duplicated(subset=["vendor_id", "invoice_amount"], keep=False)
    duplicates_df = df[duplicate_mask]
    
    for _, row in duplicates_df.iterrows():
        findings.append({
            "rule": "Exact Duplicate Payment",
            "invoice_id": row["invoice_id"],
            "vendor": row["vendor_name"],
            "amount_at_risk": row["invoice_amount"],
            "note": f"Matched vendor and amount (${row['invoice_amount']:,.2f})"
        })

    # ----------------------------------------------------
    # RULE 2: Find Tax Overpayments (> 15% of invoice amount)
    # ----------------------------------------------------
    # Use a simple mathematical filter on the columns
    tax_mask = df["tax_amount"] > (df["invoice_amount"] * 0.15)
    tax_df = df[tax_mask]
    
    for _, row in tax_df.iterrows():
        findings.append({
            "rule": "Tax Overpayment Anomaly",
            "invoice_id": row["invoice_id"],
            "vendor": row["vendor_name"],
            "amount_at_risk": row["tax_amount"],
            "note": f"Tax amount is unusually high relative to invoice total."
        })

    # ----------------------------------------------------
    # 3. Export Results to CSV
    # ----------------------------------------------------
    if findings:
        report_df = pd.DataFrame(findings)
        report_df.to_csv("ap_audit_summary.csv", index=False)
        
        print(f"Audit Complete! Flagged {len(report_df)} exceptions.")
        print(report_df.to_string(index=False))
        print("\nReport saved successfully to 'ap_audit_summary.csv'.")
    else:
        print("No anomalies found.")

if __name__ == "__main__":
    run_simple_audit()