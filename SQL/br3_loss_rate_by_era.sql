-- BR-3: What is the documented loss rate, and did it change across the three eras?
-- Denominator = submitted jobs per era (application_number populated)
-- Numerator = fact_lost_rebates entries, assigned to era by the JOB'S OWN SUBMISSION ERA
-- where a match exists (not the loss record's own date/section label) - this matters for
-- one record (job #7565) submitted in 2025 but not flagged as lost until 2026; counting it
-- under the job's real submission era is the methodologically correct choice, and matches
-- the dashboard's DAX logic (effective_era).

WITH submitted_by_era AS (
    SELECT era, SUM(CAST(submitted AS INT)) AS jobs_submitted
    FROM fact_pse_jobs
    GROUP BY era
),
losses_with_effective_era AS (
    SELECT
        l.loss_id,
        l.amount_lost,
        COALESCE(j.era, l.era) AS effective_era
    FROM fact_lost_rebates l
    LEFT JOIN fact_pse_jobs j ON l.job_id = j.job_id
),
losses_by_era AS (
    SELECT effective_era AS era, COUNT(*) AS jobs_lost, ROUND(SUM(amount_lost), 2) AS amount_lost
    FROM losses_with_effective_era
    GROUP BY effective_era
)
SELECT
    s.era,
    s.jobs_submitted,
    COALESCE(l.jobs_lost, 0) AS jobs_lost,
    COALESCE(l.amount_lost, 0) AS amount_lost,
    ROUND(100.0 * COALESCE(l.jobs_lost, 0) / s.jobs_submitted, 2) AS documented_loss_rate_pct
FROM submitted_by_era s
LEFT JOIN losses_by_era l ON s.era = l.era
ORDER BY s.era;
