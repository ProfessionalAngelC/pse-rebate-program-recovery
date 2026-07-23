-- BR-7: Connection to the estimate-accuracy project (formerly "Project 1")
-- Question: how strong is the real, itemized connection between this program's documented
-- losses and the estimator-side data quality problem the other project addresses?

-- Overall: what share of documented losses are estimator-attributable
SELECT
    responsible_party,
    COUNT(*) AS loss_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fact_lost_rebates), 1) AS pct_of_total,
    ROUND(SUM(amount_lost), 2) AS total_amount_lost
FROM fact_lost_rebates
GROUP BY responsible_party
ORDER BY loss_count DESC;

-- 2026 specifically: the era with the highest documented loss rate (BR-3) -
-- does the responsible-party pattern support "estimator gaps," not "processor decline"?
SELECT
    l.responsible_party,
    COUNT(*) AS loss_count_2026
FROM fact_lost_rebates l
LEFT JOIN fact_pse_jobs j ON l.job_id = j.job_id
WHERE COALESCE(j.era, l.era) = '2026'
GROUP BY l.responsible_party
ORDER BY loss_count_2026 DESC;
