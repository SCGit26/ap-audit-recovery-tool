-- ============================================================================
-- Project: Automated AP Duplicate Payment & Audit Recovery Tool
-- File: audit_detection_rules.sql
-- Description: Runs multi-rule leakage detection against ap_audit_transactions.
-- ============================================================================

-- 1. RULE 1: Exact Duplicate Invoice & Payment Detection
SELECT 
    'Exact Duplicate' AS anomaly_type,
    i1.invoice_id AS original_invoice_id,
    i2.invoice_id AS flagged_duplicate_id,
    i1.vendor_id,
    i1.vendor_name,
    i1.invoice_amount AS recovery_potential_usd,
    i1.invoice_date AS original_date,
    i2.invoice_date AS duplicate_date,
    ABS(i2.invoice_date - i1.invoice_date) AS days_apart
FROM public.ap_audit_transactions i1
JOIN public.ap_audit_transactions i2 
  ON i1.vendor_id = i2.vendor_id 
 AND i1.invoice_amount = i2.invoice_amount
 AND i1.invoice_id <> i2.invoice_id
WHERE ABS(i2.invoice_date - i1.invoice_date) <= 45
  -- Ensures we only return each pair once
  AND i1.invoice_id < i2.invoice_id;

-- 2. RULE 2: Split-Requisition / Threshold Bypass Detection (Same Vendor, Same Day, Multiple Invoices)
SELECT 
    'Split Requisition / Threshold Bypass' AS anomaly_type,
    vendor_id,
    vendor_name,
    invoice_date,
    COUNT(invoice_id) AS invoice_count,
    SUM(invoice_amount) AS total_grouped_spend_usd,
    STRING_AGG(invoice_id, ', ') AS associated_invoice_ids
FROM public.ap_audit_transactions
GROUP BY vendor_id, vendor_name, invoice_date
HAVING COUNT(invoice_id) >= 2 AND SUM(invoice_amount) > 15000
ORDER BY total_grouped_spend_usd DESC;

-- 3. RULE 3: Tax Overpayment Anomalies (Tax exceeding 15% of invoice amount)
SELECT 
    'Tax Overpayment Anomaly' AS anomaly_type,
    invoice_id,
    vendor_id,
    vendor_name,
    invoice_amount,
    tax_amount,
    ROUND((tax_amount / invoice_amount) * 100, 2) AS tax_percentage
FROM public.ap_audit_transactions
WHERE (tax_amount / NULLIF(invoice_amount, 0)) > 0.15;