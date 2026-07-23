# Assumptions & Limitations Log — PSE Rebate Program Recovery (Project 2)
**Companion to:** `01_discovery_and_stakeholder_notes.md`, `02_data_profiling_notes.md`
**Status:** Living document — updated as new decisions are made during cleaning, analysis, and dashboard build. Each entry is dated to the point in the process it was decided.

Purpose: every non-obvious judgment call made about this dataset is recorded here, with the reasoning behind it and what was ruled out. This is the artifact that lets someone (an interviewer, a future version of you, or PSE itself) trace exactly how a number in the final dashboard was arrived at.

---

## 1. Resolved decisions

### 1.1 Scope: PSE-only
**Decision:** Analysis covers only the `2024 PSE`, `2025 PSE`, `2026 PSE` tabs and the PSE section of `LOST REBATES`. The workbook's other program tabs (Tacoma Power, Cascade Gas, Clallam PUD, Lewis PUD, PUD, SnoPUD, Cowlitz PUD) are excluded.
**Why:** A single, fully-owned program with a clean before/after story is a stronger portfolio artifact than a shallow multi-program sweep. The documentation framework's extension to other utilities is mentioned in the README as a single line, not built out as parallel analysis.

### 1.2 Outcome source of truth: `LOST REBATES` tab, not cell color
**Decision:** Whether a rebate was lost/denied is determined by the presence of a matching entry in the `LOST REBATES` tab (PSE section) — not by the fill color on the customer name cell in the main tracker tabs.
**Why:** Cell color (green = default/"processed," non-green = flagged) was the original hypothesis, but cross-checking all 14 `LOST REBATES` entries against their main-tab rows showed color is unreliable as a final-outcome marker: 6 of 14 known losses were still colored green. Root cause, per the program owner: color reflects status *as of the last time the row was touched*, and isn't reliably revisited once PSE issues a final decision. One case (Dana Tupa-Vento, job #7558) has a green cell but an exact dollar match to a full-loss entry in `LOST REBATES` — treated as a stale color, not a data conflict, and not used as a reason to distrust the log.
**Alternative considered and rejected:** Using color as the primary signal and `LOST REBATES` only for dollar figures. Rejected because color under-counts real losses by more than 40% in the matched sample.

### 1.3 "Submitted" definition
**Decision:** A job counts as "submitted to PSE" if the `Application #` field is populated in its main-tab row.
**Why:** Job # alone is assigned internally regardless of whether the paperwork was ever filed with PSE; `Application #` is PSE's own reference number, so its presence is the closest available proxy for "actually left our office and reached PSE." Fill rates: 2024 = 144/150 (96%), 2025 = 227/231 (98%), 2026 = 87/98 (89%, partial year).
**Limitation:** This will slightly undercount "submitted" for 2026 since it's a partial year in progress — some blank-Application# rows there may just not have reached that stage yet, not been abandoned.

### 1.4 Dollar loss: itemized, not blended — corrected twice (duplicate, then a mislogged amount)
**Decision:** The loss figure is built bottom-up from the `LOST REBATES` (PSE) entries. Two corrections were made during the actual cleaning build:
1. **Duplicate removed:** job #8029 (Saravan Natarajan) appeared twice under two different section labels — kept once (§1.10b).
2. **Mislogged amount corrected, confirmed by the program owner:** job #7646 (Megan Vilsizor) logged $5,551.20 in `LOST REBATES`, but the main tracker shows only $4,201.20 was ever received for that job. Every other partial-writedown record in the log clearly represents the true shortfall (a number *smaller* than what was ultimately received) — this was the one exception, representing the original pre-adjustment claim instead. Confirmed directly: the real loss on this job was **$1,350.00** (the difference), not the full $5,551.20 originally logged.
**Corrected total: $27,656.85 across 13 distinct lost/denied jobs** (previous figures of $34,178.55 and $31,858.05 were intermediate, pre-correction values — not used anywhere downstream). Within that total, entries are tagged as **full loss** (claim fully rejected) or **partial write-down** (job largely succeeded, partial amount disallowed), with two further records held out as `unknown` (§1.10a) rather than force-classified.
**Why this matters:** This is the second time in this project that taking a source number at face value would have overstated the headline figure. Both times, checking the number against a second, independent field in the data (rather than trusting the log in isolation) is what caught it.

### 1.5 Unmatched record: Krebser job (#6343)
**Decision:** This `LOST REBATES` entry ("no photos existed by the time it was filed," $5,820, dated 6/12/2024) could not be matched by job number to any row in the three main tracker tabs. It's retained as a standalone loss record — the `LOST REBATES` tab already contains everything needed (date, amount, reason, estimator) without requiring a join.
**Open note:** It's plausible this job was never logged in the main tracker at all, i.e., it fell through the cracks before ever being entered — which would actually be a real, if anecdotal, example of the exact documentation gap this project addresses. Not confirmed; noted as an observation, not a claim.

### 1.6 Immediate data hygiene fixes (not portfolio-related, just necessary)
- Deleted a literal password found in `2025 PSE` row 15 notes column ("Adobe Password info: AdobePower5$").
- Redacted the employee name embedded in a `LOST REBATES` reason field ("Duct Seal Rebates Never Submitted by Dustin") — rewritten to remove the named individual per rule #1, since this is free text, not a column that anonymizes by relabeling a header.

### 1.7 Intervention timeline — three eras, mapped to source tabs
**Decision:** Confirmed by the program owner. Three distinct eras, which map cleanly onto the three tabs in the source file:
- **Pre-2024 (out of scope, background only):** PSE was managed by the accounting team through 2023, following prior years of significant losses; accounting was also unable to stabilize it. No corresponding tab exists in the dataset — this period is narrative/background context in the README only, same treatment as the $100K figure (§2.1), not a quantitative comparison point.
- **2024 — "Solo turnaround" era:** Program owner took over PSE personally, learned PSE's requirements from the ground up, and processed the large majority of the program's paperwork directly. Matches `2024 PSE`, the earliest tab in the file.
- **2025 — "Training / oversight" era:** Program owner began training team members (Vanessa, Beatriz, Tania, Dustin, Angel) to process PSE paperwork, while retaining oversight. Matches `2025 PSE`.
- **2026 — "Single dedicated processor" era:** Responsibility handed off to one dedicated processor. Matches `2026 PSE` (partial year, data through July 2026).
**Why this axis, not a single cutoff date or per-person staggered date:** It's directly supported by the file's own structure (one tab per era) rather than requiring inference, and it avoids relying on the sparse processor-name data (§1.9).
**Limitation:** A true "before" baseline (pre-2024, under accounting) does not exist in this dataset. The before/after story this project can actually prove is *within* the program-owner-led era (2024 solo → 2025 team-training → 2026 single processor), not a comparison against the original accounting-team failure period.

### 1.8 Field-created vs. office-created profile origin — no statistical test, but a real evidentiary link
**Decision:** Confirmed directly by the program owner: all estimators appearing in this dataset (Wendy, Carlos, Rob, Steve) created job profiles in the field for the entire 2024–2026 period this data covers. There is no office-created comparison group, so a field-vs-office **rate comparison cannot be computed** from this dataset — that claim is correctly out of scope.
**What *can* be shown instead:** Project 1's insight (that certain estimator-side data errors could have been caught earlier by an office review step) originated from the program owner reviewing denial reasons in this exact dataset. Two of the 14 `LOST REBATES` entries are specifically unverified/incorrect job-detail errors, not eligibility or paperwork-timing issues:
  - Billy Mitchell's job — reason: "Failed to check primary heat source"
  - Kathleen Johnson's rental job — reason: "Wrong heating source"
These are cited in the cross-reference note as **concrete, named, dated examples of the failure category Project 1's review checkpoint addresses** — not as a rate or a correlation. Language used: "examples of," not "proof of" or "correlated with X%."
**How this is framed in the cross-reference note:** Project 1's fix was prompted by patterns observed in this program's real denial data; two specific records above illustrate the failure type. No population-level or statistical claim is made connecting the two projects.
**Ruled out:** Computing any field-vs-office rate (no comparison population exists) and inferring field/office status from indirect proxies — both would be fabricating a signal rather than reporting one that exists.

### 1.9 Processor-name field (`2025 PSE` notes column) — not usable as a cohort dimension
**Decision:** The column containing trainee processor names (Vanessa, Beatriz, Tania, Dustin, Angel) is populated on only 5 of 231 rows in `2025 PSE` (~2%) — all appearing to be a one-time note logged at the start of training, not an ongoing tracked field. Not used for any quantitative cohort comparison.
**What's used instead:** The `Estimator` column (Wendy, Carlos, Rob, Steve — the salesperson/field role, confirmed by the program owner, distinct from the processor role) is well-populated (89–98% fill rate across all three years) and is used as the real cohort dimension for estimator-level rejection-rate analysis, anonymized to cohort labels per rule #1.

### 1.10a Loss-type classification: a third category was needed, discovered during cleaning
**Decision:** Building `fact_lost_rebates` required comparing each loss amount to the matching job's claimed `PSE Amount` to classify it as a full loss vs. a partial write-down (per §1.4). Two records couldn't be classified this way and needed a third, honest label rather than being forced into one of the two:
- **Job #6343 (Krebser)** — `unknown_no_matching_job` — no row exists for this job anywhere in the main tracker tabs (§1.5).
- **Job #6876 (Kathleen Johnson's rental job)** — `unknown_claimed_amount_missing` — this job *does* exist in the main tracker (it's the row we already identified as red-colored), but its `PSE Amount` field was left blank on that row, so there's nothing to compare the $2,700 loss against.
**Why this matters:** Forcing these into "full_loss" or "partial_writedown" would have been a guess dressed up as a data-driven classification. A third explicit category is the more honest choice.

### 1.10b Duplicate resolution direction, corrected during the cleaning build
**Decision:** When building the de-duplication logic for job #8029 (§1.4), the first version of the script kept whichever of the two duplicate rows happened to appear first in the source tab — which turned out to be the row with a **blank** reason field, dropping the row that actually explained the denial ("Attic work was part of restoration does not qualify"). Corrected to keep whichever duplicate has more information (a populated reason), not just whichever comes first.
**Why this matters:** This is exactly the kind of silent, plausible-looking-but-wrong result that's worth catching before it reaches a dashboard — the total dollar figure would have been identical either way, but the reason categorization (§3, `fact_lost_rebates`) would have quietly lost real information.

### 1.10c Additional PII found during pipeline build: a customer name leaked into a dollar-amount field
**Decision:** While coercing `client_amount` to numeric, 4 rows in `2024 PSE` contained non-numeric text instead of a dollar figure — three were workflow status notes ("is completed?", "REFUND 1000 TO CLIENT," "need signature and full payment"), and one was **a customer's full name typed directly into that column** ("Janet Thompson"). All four are nulled out in the cleaned dataset rather than retained as text.
**Why this matters:** This is the third PII-adjacent finding in this file, after the exposed password (§1.6) and the employee name embedded in a denial reason (§1.6). None of these were caught by looking at the data structurally (column headers, types) — all three only surfaced by actually processing every cell's real value. Worth remembering for any future raw export from this same tracker: free-text drift into "structured" columns is a recurring pattern in this file, not a one-off.

### 1.12 Responsible-party attribution for loss reasons — fully resolved
**Decision:** The program owner clarified real role boundaries that let all 13 loss records be attributed to whoever was actually responsible:
- **Estimator (9 records)** — eligibility misses (scope, house age, insulation caps) and duplicate/overlapping claims, plus 2 direct data-capture errors (heat source).
- **Crew (1 record)** — photo documentation (Krebser job).
- **Office/billing staff (1 record)** — Melissa Crumb's job ("not invoiced").
- **Processor (1 record)** — Jeff Koslosky's job ("never submitted"), confirmed as a mistake by a processor who left the role in March; the processor in place since March has no documented mistakes in this dataset. Note: this job was submitted in August 2025, so it's assigned to the 2025 era under this project's era methodology, not 2026.
- **Unrecorded (1 record)** — no reason logged.
**Final breakdown: 9 estimator / 1 crew / 1 office-billing / 1 processor / 1 unrecorded.**

**Why this matters for the Project 1 cross-reference:** 9 of 13 (69%) documented losses are estimator-attributable — a real, itemized connection to Project 1, not the original 2-example framing. For 2026 specifically: 4 of 5 losses are estimator-attributable, 1 is billing-staff, **zero are attributed to the processor active during 2026** — directly supporting the program owner's account that the rising 2026 loss rate tracks estimator-side gaps, not a decline from consolidating PSE submission to one processor.

**Known limitation, disclosed rather than modeled around:** this project's era boundaries (2024/2025/2026, mapped to the source tabs) are a useful but simplified proxy for actual staffing history — there was a real processor transition around March that doesn't align with the Jan 1 tab boundaries, and the underlying data doesn't reliably support splitting 2026 into "before vs. after that transition" (the processor-identity field is sparse — see §1.9). Rather than fabricate that split, it's disclosed here as a limitation of the era model.

**Honest caveats that still apply, regardless of how clean this story now looks:**
- Sample size remains small (13 records total, 5 in 2026) — suggestive, not statistically proven.
- "Zero losses attributed to the processor" is not the same claim as "the processor made zero mistakes" — it means no *documented, logged* loss in this dataset was attributed to processor error. Absence from this log isn't proof of a clean record, especially given §2.2 (whether `LOST REBATES` is an exhaustive log is still unconfirmed).
- These caveats are kept in the README, not dropped just because the underlying finding turned out to support the intended narrative.

### 1.13 Estimator cohort backfilled from the main tracker when the loss log itself was blank
**Decision:** Two `LOST REBATES` records (Teri Bevelacque's job #7867, Melissa Crumb's job #8007) had a blank `Estimator` field in the log itself, initially shown as "Unattributed." Both job numbers exist in the main tracker tabs, which have their own, better-populated `Estimator` field — Estimator C and Estimator B respectively, confirmed directly, not inferred. The loss record's `estimator_cohort` now falls back to the main tracker's value whenever the log's own field is blank.
**Why this is a legitimate fix, not a guess:** this pulls from a second real, already-verified data source already used throughout this project (the same `Estimator` field powering `fact_pse_jobs`), joined by the same `job_id` key already established as reliable (§2 of the data dictionary). Nothing is fabricated — it's using data that was already sitting in the file.
**What this does NOT change:** `responsible_party` is unaffected — Melissa Crumb's record was already correctly attributed to `office_billing`, not the estimator, regardless of which estimator's job it technically was. "Whose job was it" and "who caused the loss" remain two separate, independently-tracked facts (see §1.12).

### 1.14 Duplicate job_id entries found and removed from fact_pse_jobs
**Decision:** While setting up the Power BI relationship, `job_id` was found to be non-unique in `fact_pse_jobs` — 10 job numbers each appeared on 2 rows (469 unique out of 479 total). The program owner confirmed the underlying business rule directly: job IDs are meant to uniquely identify a single job and should never repeat — any repeat is an entry error, not a legitimate coincidence.
**Resolved (5 pairs, confirmed and removed):**
- Job #6895 — same job, logged in both the 2024 and 2025 tabs on the same date (2024-12-26); kept the 2025 entry (complete, has a claimed amount), dropped the 2024 entry (blank amount).
- Job #7772, #7998 — same job logged twice, days to weeks apart, identical claimed amount both times; kept the earlier entry in each case, dropped the later re-entry.
- Job #8463, #8601 — same job logged twice on the exact same date with an identical claimed amount; arbitrarily kept the first-listed row in each case (the two entries were otherwise indistinguishable).
**Impact:** `fact_pse_jobs` reduced from 479 to 474 rows. 2025 figures are completely unaffected (none of the 5 removed rows were 2025). 2024 total jobs: 150 → 149 (dollar total effectively unchanged, the removed row had no claimed amount). 2026 total jobs: 98 → 94, submitted: 87 → 83, total claimed: $300,044.75 → $288,812.80.
**Still open:** 5 further duplicate job-ID pairs (#6113, #6156, #6152, #6197, #6597) — RESOLVED. Confirmed by the program owner: in 2024 specifically, the source column (`Invoice # or estimate`) mixed two different numbering sequences — estimate numbers and actual job/invoice numbers — into a single field. These 5 pairs are two genuinely different, unrelated real records (an estimate and a separate job, or two separate jobs) that happen to share a number because they come from different sequences, not the same job entered twice. **No rows removed for these 5 pairs** — both records in each pair are kept as-is.
**Disclosed limitation this reveals:** `job_id` is not a fully reliable unique key specifically for 2024 records, due to this estimate/job number conflation in the source column. This doesn't affect any already-verified result (none of these job IDs overlap with `fact_lost_rebates`, confirmed directly), but is worth disclosing for anyone joining on `job_id` against 2024 data in the future.
**Additional verification performed:** checked `application_number` (PSE's own external reference number, not an internally-assigned one) for duplicates across all 454 populated rows post-fix — zero duplicates found. Since this field comes from PSE itself rather than internal numbering, it's a stronger independent check than `job_id` alone, and its cleanliness increases confidence that the 5-row fix above resolved the real duplication issue rather than just one symptom of it.
**Why this matters:** none of the 10 original duplicate job IDs (confirmed or still-open) overlap with any of the 13 records in `fact_lost_rebates` — so BR-1, BR-3, BR-4, BR-5, and BR-7 are completely unaffected by this issue. Only BR-2's job counts and dollar totals needed correcting.

### 1.15 BR-6 completed: submission-to-approval cycle time dropped sharply across eras
**Decision:** The disclosed random sample (§1.11, n=24, 8 per era, fixed seed) was completed via manual PSE portal lookups. Results, verified against a second independent field (portal dollar amounts matched the original tracker in 22 of 24 cases; the 2 mismatches were confirmed as data-entry typos, not real discrepancies, and don't affect approval dates):

| Era | n | Average cycle time | Range |
|---|---|---|---|
| 2024 | 8 | 87.8 days | 35–171 |
| 2025 | 8 | 46.8 days | 12–74 |
| 2026 | 8 | 9.2 days | 2–20 |

**This is the one metric in the entire project showing a clean, uninterrupted improvement across all three eras** — unlike the documented loss rate, which climbed. Reported as a genuine finding, not overstated.
**Honest caveats:**
- Sample-based (n=8/era), same as always — directional, not a precise population statistic.
- Possible right-censoring risk for 2026 specifically: only jobs with an *already-completed* approval could appear in this sample. A recently-submitted, slow-to-process 2026 job might not have shown a finished approval yet at the time of lookup, and so couldn't be captured — meaning the true 2026 average could be somewhat higher than 9.2 days once slower-processing jobs (if any) resolve. As it happened, all 8 randomly-sampled 2026 jobs already had a completed approval, so this risk didn't materially affect this particular sample, but it's a structural limitation worth disclosing for any future re-run against a still-in-progress year.

### 1.16 SQL and Power BI reconciled on loss-rate era assignment
**Decision:** The Power BI dashboard's `effective_era` measure correctly assigns job #7565 (Koslosky, "never submitted") to its actual submission era (2025), not the era it was logged as lost (2026) — this was built correctly from the start. The BR-3 SQL query, however, was never updated to match, and used the loss record's raw date instead, producing a different (less correct) figure. Caught when the program owner reported the live Power BI figure (6.02% for 2026) didn't match the SQL-derived figure (7.23%) — a discrepancy that traced back to this exact inconsistency, not a new data error.
**Resolution:** SQL updated to match the dashboard's logic exactly. **Final, reconciled rate: 1.39% → 2.64% → 6.02%**, confirmed identically in both SQL Server and Power BI.
**Why this matters:** This is the kind of quiet inconsistency that's easy to miss when two tools built at different points in a project answer the same question slightly differently — worth the reminder that "it runs without an error" isn't the same as "it agrees with everything else in the project."

### 1.10 Spreadsheet structure evolved because processors were given ownership of it, not because of inconsistent management
**Decision:** The tracking sheet's column structure changes year to year (e.g., `2024 PSE` has an explicit `Status` column that `2025`/`2026 PSE` don't). Framing: the program owner designed and owned the underlying compliance framework and process (PSE requirements, documentation standards, photo procedures), and the sheet's day-to-day layout was then adapted by the processors actually using it. Core compliance requirements stayed consistent; the tracking tool's exact layout evolved with real usage.
**Why this matters:** Prevents a reviewer from misreading year-to-year format drift as inconsistent process ownership. One sentence to this effect goes in the README's methodology/background section.

### 1.11 Submission-to-approval cycle time: reopened via disclosed random sample
**Decision:** BR-6 was originally marked out of scope (§ Business Requirements doc) because no approval-date field exists in any tab. The program owner confirmed PSE's own portal does contain approval dates, but only retrievable by manual per-client lookup — not feasible for the full ~470-record submitted population.
**Method:** A random sample of 8 records per era (24 total) was drawn from the "submitted" pool (`Application #` populated, per §1.3) using a fixed, documented random seed (`seed=42`) in Python, so the sample is reproducible and verifiably not hand-picked. Sample stored in `04_approval_date_sample_to_collect.csv`.
**Why a fixed seed matters here:** Cherry-picking which records to look up (e.g., ones remembered as fast) would bias the resulting cycle-time metric. A documented random draw is the standard way to avoid that, and the seed makes the sample reproducible if questioned.
**Status:** Sample generated, approval dates not yet collected. Once returned, this becomes a real but explicitly sample-based metric (n=24, ~5% of the submitted population) — reported as such, not extrapolated as if it were a full-population figure. One row (Ross Smith, job #8178, 2026) has a malformed date in the source file, flagged for manual verification against the portal directly.

### 2.1 The $100K pre-tenure figure
**Status:** Not independently verified. Sourced from a verbal statement by leadership about losses prior to the program owner's tenure. Will appear in the README's background section only, explicitly labeled as management-reported context — never combined with the $34,178.55 documented-loss figure calculated from this dataset.

### 2.2 Is `LOST REBATES` a complete log, or best-effort?
**Status:** Still open. The program owner has confirmed the log is *trustworthy* for what it records — but hasn't confirmed it captures every denial that ever happened. This affects framing: if the log is exhaustive, we can fairly call the resulting number a "rejection rate." If it's best-effort, the more honest framing is "documented loss rate" — a lower-bound, not a comprehensive rate. **Defaulting to the more conservative "documented loss" framing until confirmed otherwise.**

### 2.3 Blank `Status` field in `2024 PSE`
**Status:** Still open. 80% of rows in that column are blank. Not yet confirmed whether that means "not yet submitted at time of snapshot," "approved but never marked," or something else. Currently not relied upon for any metric (superseded by the `LOST REBATES`-based methodology in §1.2), so this is lower priority, but still worth resolving for completeness.

---

## 3. Scope boundary reminder
Per the program owner's framing rules for this project:
- No real individual employees named or ranked in any public-facing artifact — cohort labels only.
- No dollar-loss figure used without being traceable to specific, itemized records.
- No mixing of before-period and after-period metrics that aren't measuring the same thing.
- "Associated with" / "correlated with" language only for the profile-creation-error link (Project 1 cross-reference) unless data clearly supports stronger language.
