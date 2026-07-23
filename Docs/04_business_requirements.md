# Business Requirements — PSE Rebate Program Recovery (Project 2)
**Companion to:** `01_discovery_and_stakeholder_notes.md`, `02_data_profiling_notes.md`, `03_assumptions_and_limitations_log.md`
**Purpose:** Define exactly what questions this analysis answers, why each one matters, what data supports it, and — honestly — what it can't answer with the data available. Every SQL query and dashboard visual in this project traces back to one of these.

---

## BR-1: What is the documented dollar loss from PSE rebate denials, and how is it broken down?
**Why it matters:** This is the core financial claim of the project. It needs to be a real, itemized number a reader can trace back to specific records — not a round figure.
**Data:** `LOST REBATES` tab (PSE section) — `Amount`, `Reason`, `Date`, `Estimator`.
**Definition:** Sum of 13 distinct documented loss records = **$27,656.85** (assumptions log §1.4 — corrected twice during cleaning: one duplicate record removed, one mislogged amount corrected and confirmed with the program owner), split into:
- **Full losses** — entire claimed amount rejected ($13,151.90, 5 records)
- **Partial write-downs** — job was substantially approved, a portion of the claim was disallowed ($5,984.95, 6 records)
- **Unclassified** — 2 records that can't be cleanly assigned to either category due to missing comparison data ($8,520.00 combined — see assumptions log §1.10a)
**Status:** Answerable now.

---

## BR-2: How did submission volume and claimed dollar value change across the program's three operational eras?
**Why it matters:** This is the growth/stabilization story — proof the program scaled under your ownership, using parallel metrics (rule #3: no mixing mismatched measures).
**Data:** `2024 PSE`, `2025 PSE`, `2026 PSE` — row counts and `$ PSE Amount` / `PSE Amount` sums per tab.
**Definition:** Era = source tab (per assumptions log §1.7): 2024 = solo turnaround, 2025 = team-training, 2026 = single dedicated processor (partial year — reported as a run-rate, not compared directly to full-year totals).
**Status:** Answerable now.

---

## BR-3: What is the documented loss rate, and did it change across the three eras?
**Why it matters:** This is the direct evidence that the program got measurably healthier under your process, not just bigger.
**Data:** Denominator = jobs with `Application #` populated per tab (§1.3). Numerator = `LOST REBATES` entries, assigned to era by **the job's own submission era where a match exists** (not the loss record's raw date or section label).
**Definition:** Documented loss rate = (LOST REBATES entries whose underlying job was submitted in era X) ÷ (submitted jobs in era X).
**Methodology reconciliation (important):** One record (job #7565, "never submitted") was submitted in 2025 but not flagged as a loss until 2026. Assigning it to its actual submission era (2025) rather than the date the loss was logged (2026) is the methodologically correct choice — it answers "how did jobs submitted in this era perform," not "when did we happen to notice a problem." This is the same logic used in the Power BI dashboard's `effective_era` measure; the SQL query was updated to match it after an earlier version used the loss record's raw date and produced a slightly different, less correct figure. Both tools are now fully consistent.
**Final verified rate: 1.39% (2024) → 2.64% (2025) → 6.02% (2026)** — climbing across all three eras, confirmed identically in SQL Server and Power BI.
**Important framing note:** Per §2.2, this is reported as a **"documented loss rate,"** not a "rejection rate" or "approval rate," unless you confirm `LOST REBATES` is an exhaustive log. This is a defensible lower bound either way.
**Status:** Answerable now, fully verified and reconciled across both tools.

---

## BR-4: How does documented loss rate vary by estimator cohort, and by responsible party?
**Why it matters:** Useful operational insight (were certain cohorts more error-prone, and did that change over time), handled carefully per rule #1 — cohort labels only, no named individuals, no ranking.
**Data:** `Estimator` field (Wendy/Carlos/Rob/Steve → Estimator A/B/C/D), well-populated (89–98% fill rate) in `fact_pse_jobs`; `responsible_party` field in `fact_lost_rebates` (assumptions log §1.12).
**Definition:** Two related but distinct views: (1) loss rate by estimator cohort — which cohort's *jobs* had the most documented losses; (2) loss count by responsible party — of the 13 documented losses, who was actually responsible (9 estimator, 1 crew, 1 office-billing, 1 processor, 1 unrecorded). The second view is the one that matters for the cross-reference to the estimate-accuracy project (BR-7).
**Status:** Answerable now. Note: `Estimator` is the *salesperson/field* role, not the PSE processor role (§1.9) — labeled precisely as such in the dashboard so it isn't confused with processing-team performance.

---

## BR-5: What are the most common reasons rebates were lost, and who was responsible?
**Why it matters:** Separates "this was preventable through better process" from "this was never going to qualify no matter what" — an honest distinction, and the one that connects to the estimate-accuracy project.
**Data:** `LOST REBATES` → `reason_category` and `responsible_party` fields, both categorized.
**Definition:** Reasons bucketed by topic (*eligibility*, *admin/duplicate claim*, *documentation/timing*, *data-capture error*) and separately by responsible party (*estimator*, *crew*, *office/billing*, *processor*, *unrecorded*) — see assumptions log §1.12 for the full reasoning behind each attribution.
**Status:** Answerable now — 13 distinct records (after deduplication, §1.4), manually categorized and documented (small n, reported as categorized counts, not a statistical distribution).

---

## BR-6: Time from submission to approval, and whether it improved
**Why it matters:** Operational speed is a natural before/after indicator.
**Data available:** No approval-date field exists in any tab; recovered via a disclosed random sample (n=24, 8/era, fixed seed) with manual PSE portal lookups.
**Finding:** Average cycle time dropped sharply across all three eras — **87.8 days (2024) → 46.8 days (2025) → 9.2 days (2026)**, a ~90% reduction. This is the one metric in the project showing a clean, uninterrupted improvement across every era.
**Status:** ✅ Complete. Reported as sample-based (n=8/era), not a full-population statistic — see assumptions log §1.15 for the full methodology and a disclosed right-censoring caveat specific to the 2026 figure.

---

## BR-7: Connection to Project 1 (estimator profile-creation accuracy)
**Why it matters:** The two projects share subject matter and a real originating link. This question asks exactly how strong that link is, using this program's own real denial data — not more, not less than the evidence supports.
**Data:** All 13 documented `LOST REBATES` records, categorized by `responsible_party` (assumptions log §1.12).
**Finding:** **9 of 13 (69%) documented losses are estimator-attributable** — eligibility checks the estimator should have made before scoping the job, duplicate-claim checks, and direct data-capture errors (heat source). The remaining 4: 1 crew (photo documentation), 1 office/billing, 1 processor, 1 unrecorded.
**Era detail:** Specifically for 2026 — the year the loss rate rose most (BR-3) — 4 of 5 losses are estimator-attributable and **zero are attributed to the processor active that year**, supporting the program owner's account that the 2026 uptick tracks continued estimator-side gaps, not a decline from consolidating PSE submission to a single processor.
**What this is NOT:** A field-vs-office statistical comparison — every job in this dataset was created in the field, so no such comparison population exists (§1.8). This is also not proof that Project 1's fix *worked* — this program's data predates and doesn't overlap with that fix; it's evidence the underlying problem was real, not evidence the solution succeeded.
**Honest caveats carried forward:** small sample (13 records total, 5 in 2026); "zero processor-attributed losses" means none were *logged* as processor error in this dataset, not a confirmed clean record (§2.2, whether the log is exhaustive is still unconfirmed).
**Status:** Answerable now, with a real, itemized percentage — a substantially stronger connection than the original 2-example framing.

---

## Summary: what's in scope for SQL/dashboard, and what isn't

| # | Question | Status |
|---|---|---|
| BR-1 | Itemized dollar loss | ✅ In scope |
| BR-2 | Volume/value by era | ✅ In scope |
| BR-3 | Documented loss rate by era | ✅ In scope |
| BR-4 | Loss rate by cohort & responsible party | ✅ In scope |
| BR-5 | Loss reasons categorized, by topic and responsible party | ✅ In scope |
| BR-6 | Submission-to-approval time | ✅ Complete — 87.8 → 46.8 → 9.2 days, sample-based (n=8/era) |
| BR-7 | Estimate-accuracy project cross-reference | ✅ In scope — 9 of 13 losses (69%) estimator-attributable, itemized
