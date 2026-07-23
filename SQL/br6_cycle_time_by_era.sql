-- BR-6: Time from submission to approval, and whether it improved
-- Sample-based: n=8 per era, 24 total, disclosed random sample (fixed seed=42)

SELECT
    era,
    COUNT(*) AS sample_size,
    AVG(CAST(cycle_time_days AS FLOAT)) AS avg_days,
    MIN(cycle_time_days) AS min_days,
    MAX(cycle_time_days) AS max_days
FROM sample_approval_times
GROUP BY era
ORDER BY era;
