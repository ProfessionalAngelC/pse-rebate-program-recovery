-- BR-1: What is the documented dollar loss from PSE rebate denials, and how is it broken down?
-- Source: fact_lost_rebates (13 distinct records, deduplicated from 14 raw log entries)

SELECT
    loss_type,
    COUNT(*) AS record_count,
    ROUND(SUM(amount_lost), 2) AS total_amount
FROM fact_lost_rebates
GROUP BY loss_type
ORDER BY total_amount DESC;

-- Grand total (all loss types combined)
SELECT ROUND(SUM(amount_lost), 2) AS total_documented_loss
FROM fact_lost_rebates;
