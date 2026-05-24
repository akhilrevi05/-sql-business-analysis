-- =============================================
-- VENDOR COST GOVERNANCE
-- Author: Akhil Revi  
-- Description: Detects cost inflation and
-- anomalies in vendor spend data
-- =============================================

-- 1. Vendors with highest month-on-month cost increase
SELECT 
    vendor_name,
    current_month_spend,
    prev_month_spend,
    ROUND((current_month_spend - prev_month_spend) * 100.0 / prev_month_spend, 2) AS mom_change_pct
FROM (
    SELECT 
        vendor_name,
        SUM(CASE WHEN month = DATE_TRUNC('month', CURRENT_DATE) 
            THEN amount ELSE 0 END) AS current_month_spend,
        SUM(CASE WHEN month = DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month' 
            THEN amount ELSE 0 END) AS prev_month_spend
    FROM vendor_spend
    GROUP BY vendor_name
) t
WHERE prev_month_spend > 0
ORDER BY mom_change_pct DESC;

-- 2. Flag invoices above approval threshold
SELECT 
    invoice_id,
    vendor_name,
    invoice_amount,
    approval_status,
    CASE 
        WHEN invoice_amount > 10000 AND approval_status = 'pending' THEN 'HIGH RISK'
        WHEN invoice_amount > 5000 AND approval_status = 'pending' THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS risk_flag
FROM invoices
ORDER BY invoice_amount DESC;
