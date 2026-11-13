-- ============================================================================
-- Project: Automated AP Duplicate Payment & Audit Recovery Tool
-- File: audit_data.sql
-- Description: Populates ap.ap_audit_transactions with clean baseline 
--              records alongside planted duplicate invoices, fuzzy vendor 
--              duplicates, split-requisition bypasses, and tax overpayments.
-- ============================================================================

INSERT INTO ap.ap_audit_transactions (
    invoice_id, po_number, vendor_id, vendor_name, invoice_date, posting_date, 
    payment_date, invoice_amount, tax_amount, freight_amount, department
) VALUES
-- 1. Clean Baseline Transactions
('INV-1001', 'PO-5001', 'V-101', 'Apex Cloud Solutions', '2026-08-01', '2026-08-03', '2026-08-25', 14500.00, 1160.00, 0.00, 'IT'),
('INV-1002', 'PO-5002', 'V-102', 'Midwest Logistics Group', '2026-08-04', '2026-08-05', '2026-08-28', 6250.00, 500.00, 320.00, 'Operations'),
('INV-1003', 'PO-5003', 'V-103', 'Global Office Supply Co', '2026-08-07', '2026-08-08', '2026-09-01', 1840.50, 147.24, 45.00, 'Finance'),
('INV-1004', 'PO-5004', 'V-104', 'Summit Engineering Services', '2026-08-10', '2026-08-12', '2026-09-05', 28900.00, 2312.00, 0.00, 'Engineering'),
('INV-1005', 'PO-5005', 'V-105', 'Vanguard Security Systems', '2026-08-14', '2026-08-15', '2026-09-10', 11200.00, 896.00, 150.00, 'IT'),

-- 2. Exact Duplicate Payment Scenario (Same Vendor, Exact Amount, Different Invoice IDs within 12 days)
('INV-1006', 'PO-5006', 'V-102', 'Midwest Logistics Group', '2026-08-15', '2026-08-16', '2026-09-05', 8420.00, 673.60, 210.00, 'Operations'),
('INV-1006-DUP', 'PO-5006', 'V-102', 'Midwest Logistics Group', '2026-08-27', '2026-08-28', '2026-09-15', 8420.00, 673.60, 210.00, 'Operations'),

-- 3. Fuzzy / Formatting Variant Duplicate (Same Vendor ID & Amount, Invoice ID has trailing suffix/typo)
('INV-2044', 'PO-5010', 'V-101', 'Apex Cloud Solutions', '2026-09-02', '2026-09-03', '2026-09-25', 19750.00, 1580.00, 0.00, 'IT'),
('INV-2044A', 'PO-5011', 'V-101', 'Apex Cloud Solutions Inc.', '2026-09-18', '2026-09-19', '2026-10-10', 19750.00, 1580.00, 0.00, 'IT'),

-- 4. Split-Requisition / Approval Threshold Bypass (Multiple invoices same day just under $10,000 limit)
('INV-3010', 'PO-5020', 'V-106', 'Horizon Marketing Partners', '2026-09-12', '2026-09-12', '2026-10-01', 9850.00, 788.00, 0.00, 'Marketing'),
('INV-3011', 'PO-5021', 'V-106', 'Horizon Marketing Partners', '2026-09-12', '2026-09-12', '2026-10-01', 9900.00, 792.00, 0.00, 'Marketing'),
('INV-3012', 'PO-5022', 'V-106', 'Horizon Marketing Partners', '2026-09-12', '2026-09-12', '2026-10-01', 9750.00, 780.00, 0.00, 'Marketing'),

-- 5. Tax & Freight Overpayment Anomalies (Tax > 15% of invoice subtotal or excessive freight)
('INV-4001', 'PO-5030', 'V-103', 'Global Office Supply Co', '2026-09-20', '2026-09-21', '2026-10-12', 3200.00, 768.00, 45.00, 'Finance'),
('INV-4002', 'PO-5031', 'V-104', 'Summit Engineering Services', '2026-09-25', '2026-09-26', '2026-10-18', 5400.00, 432.00, 1350.00, 'Engineering'),

-- 6. Additional Clean Transactions for Statistical Volume
('INV-5001', 'PO-5040', 'V-105', 'Vanguard Security Systems', '2026-10-01', '2026-10-02', '2026-10-22', 7600.00, 608.00, 75.00, 'IT'),
('INV-5002', 'PO-5041', 'V-101', 'Apex Cloud Solutions', '2026-10-05', '2026-10-06', '2026-10-28', 15200.00, 1216.00, 0.00, 'IT'),
('INV-5003', 'PO-5042', 'V-102', 'Midwest Logistics Group', '2026-10-08', '2026-10-09', NULL, 4890.00, 391.20, 180.00, 'Operations');

-- Quick Verification Check
SELECT COUNT(*) AS total_rows_loaded, SUM(invoice_amount) AS total_ap_volume 
FROM ap.ap_audit_transactions;