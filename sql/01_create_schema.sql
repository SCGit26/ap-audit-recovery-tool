-- 1. Create the ap schema if it is missing
CREATE SCHEMA IF NOT EXISTS ap;

-- 2. Drop existing table if re-running setup
DROP TABLE IF EXISTS ap.ap_audit_transactions CASCADE;

-- 3. Create Base Table inside the ap schema
CREATE TABLE ap.ap_audit_transactions (
    invoice_id VARCHAR(50) PRIMARY KEY,
    po_number VARCHAR(50),
    vendor_id VARCHAR(50) NOT NULL,
    vendor_name VARCHAR(150) NOT NULL,
    invoice_date DATE NOT NULL,
    posting_date DATE NOT NULL,
    payment_date DATE,
    invoice_amount NUMERIC(12, 2) NOT NULL,
    tax_amount NUMERIC(10, 2) DEFAULT 0.00,
    freight_amount NUMERIC(10, 2) DEFAULT 0.00,
    department VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create Performance Indexes for Duplicate Detection
CREATE INDEX idx_audit_vendor_amount ON ap.ap_audit_transactions (vendor_id, invoice_amount);
CREATE INDEX idx_audit_invoice_date ON ap.ap_audit_transactions (invoice_date);
