-- =============================================
-- FUNNEL ANALYSIS: Study Cost Optimisation
-- Author: Akhil Revi
-- Description: Identifies drop-off points and
-- cost inefficiencies in B2B study workflows
-- =============================================

-- 1. Total studies by status
SELECT 
    study_status,
    COUNT(*) AS total_studies,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM studies
GROUP BY study_status
ORDER BY total_studies DESC;

-- 2. Average cost per study by category
SELECT 
    study_category,
    COUNT(*) AS study_count,
    ROUND(AVG(study_cost), 2) AS avg_cost,
    ROUND(MIN(study_cost), 2) AS min_cost,
    ROUND(MAX(study_cost), 2) AS max_cost
FROM studies
GROUP BY study_category
ORDER BY avg_cost DESC;

-- 3. Funnel drop-off analysis
SELECT 
    stage,
    COUNT(*) AS entries,
    LAG(COUNT(*)) OVER (ORDER BY stage_order) AS prev_stage_count,
    ROUND(
        (LAG(COUNT(*)) OVER (ORDER BY stage_order) - COUNT(*)) * 100.0 / 
        LAG(COUNT(*)) OVER (ORDER BY stage_order), 2
    ) AS drop_off_pct
FROM study_funnel
GROUP BY stage, stage_order
ORDER BY stage_order;

-- 4. Vendor cost comparison over time
SELECT 
    vendor_name,
    DATE_TRUNC('month', invoice_date) AS month,
    SUM(invoice_amount) AS total_spend,
    SUM(SUM(invoice_amount)) OVER (
        PARTITION BY vendor_name 
        ORDER BY DATE_TRUNC('month', invoice_date)
    ) AS cumulative_spend
FROM vendor_invoices
GROUP BY vendor_name, DATE_TRUNC('month', invoice_date)
ORDER BY vendor_name, month;

-- 5. Studies exceeding budget threshold
SELECT 
    study_id,
    study_name,
    study_cost,
    budget_threshold,
    study_cost - budget_threshold AS cost_overrun,
    ROUND((study_cost - budget_threshold) * 100.0 / budget_threshold, 2) AS overrun_pct
FROM studies
WHERE study_cost > budget_threshold
ORDER BY cost_overrun DESC;
