-- BR-2: How did submission volume and claimed dollar value change across the three operational eras?
-- Era = source tab (2024 = solo turnaround, 2025 = team-training, 2026 = single dedicated processor, partial year)

SELECT
    era,
    COUNT(*) AS total_jobs,
    SUM(CAST(submitted AS INT)) AS jobs_submitted,
    ROUND(SUM(pse_amount_claimed), 2) AS total_pse_amount_claimed,
    ROUND(AVG(pse_amount_claimed), 2) AS avg_pse_amount_per_job
FROM fact_pse_jobs
GROUP BY era
ORDER BY era;
