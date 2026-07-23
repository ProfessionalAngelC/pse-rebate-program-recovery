-- BR-5: What are the most common reasons rebates were lost, and who was responsible?

SELECT
    reason_category,
    responsible_party,
    COUNT(*) AS record_count,
    ROUND(SUM(amount_lost), 2) AS total_amount
FROM fact_lost_rebates
GROUP BY reason_category, responsible_party
ORDER BY record_count DESC;
