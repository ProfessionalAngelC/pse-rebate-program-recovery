-- BR-4: How does documented loss rate vary by estimator cohort, and by responsible party?
-- Note: Estimator = salesperson/field role (not the PSE processor role, see BR text)

-- View 1: loss count and amount by estimator cohort (whose jobs had losses)
SELECT
    estimator_cohort,
    COUNT(*) AS loss_count,
    ROUND(SUM(amount_lost), 2) AS total_amount_lost
FROM fact_lost_rebates
GROUP BY estimator_cohort
ORDER BY total_amount_lost DESC;

-- View 2: who was actually responsible (the more important view for this project's story)
SELECT
    responsible_party,
    COUNT(*) AS loss_count,
    ROUND(SUM(amount_lost), 2) AS total_amount_lost,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fact_lost_rebates), 1) AS pct_of_all_losses
FROM fact_lost_rebates
GROUP BY responsible_party
ORDER BY loss_count DESC;
