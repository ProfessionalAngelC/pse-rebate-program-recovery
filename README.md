# PSE Rebate Program Recovery

A real operational turnaround, documented and analyzed with real data: how a failing utility rebate program was rebuilt from the ground up, and what three years of its own records reveal about where it's still losing money — and why.

---

## Background

Evergreen Insulation LLC participates in a Puget Sound Energy (PSE) rebate program for qualifying insulation work. The program requires strict documentation, photo evidence, and paperwork compliance on a per-job basis for rebates to be approved and paid.

Before I took it over, the program was in bad shape. Leadership had reported roughly $100,000 in losses under prior management — a figure I haven't independently verified from data I have access to, so I'm not treating it as a calculated result here, just the context I inherited. What I can say with certainty: a full year under the accounting team's ownership hadn't fixed it either.

## What I Did

In 2024, I took over the program directly. I:

- Figured out exactly what PSE required for compliance — documentation standards, timing, photo evidence specifications
- Built a repeatable documentation and paperwork process from the ground up
- Trained crew members on correct procedure, including how to photograph completed jobs to PSE's exact specification
- Processed the large majority of the program's paperwork personally through that first year

In 2025, I began training team members to take over day-to-day processing, while I retained oversight. In 2026, I consolidated day-to-day processing to a single dedicated person.

This program has been running successfully since 2024. It's no longer losing money — it's generating meaningful rebate revenue every year.

## About This Analysis

The fix above is real, implemented, and still running. This repository is a separate, later effort: in 2026, I went back through the program's own historical tracking data — three years of real job records and denial logs — and built a full analysis on top of it, using SQL and Power BI, to answer specific questions about how the program actually performed and where it's still leaking value.

**This project exists to demonstrate two things a real business analysis actually requires, not just a finished dashboard:**

1. **Turning genuinely messy real data into something defensible.** The raw source file is a working spreadsheet I've used since 2024 — inconsistent formatting year to year, several real data-quality issues found and fixed along the way (a duplicated record that briefly inflated a loss total, a dollar figure that had been logged incorrectly, a couple of security/privacy issues cleaned up before anything went public). None of that was built for a portfolio; it's what a real operational tool looks like after years of real use, and cleaning it properly was as much the work as the analysis itself. Full reasoning for every decision is in `/docs`.
2. **Knowing when the data alone isn't enough, and going to get the missing context.** Several points in this analysis couldn't be resolved from the spreadsheet on its own — what a status field's blank cells actually meant operationally, who was really responsible for a specific denial, whether a numbering pattern was a data error or a legitimate quirk of how the tracker was used. I resolved these by drawing directly on my own operational knowledge of the program, the same way a BA would consult a subject-matter expert rather than guess. Where I couldn't resolve something with confidence, it's disclosed as an open limitation instead of assumed.

---

## Key Findings

### The program grew every year

| Era | Jobs Submitted | Total Claimed Value |
|---|---|---|
| 2024 (solo turnaround) | 144 | $242,324.07 |
| 2025 (team training) | 227 | $928,939.51 |
| 2026 (single processor, partial year) | 83 | $288,812.80 |

**474 jobs, $1,460,076.39 in total claimed rebate value across the full dataset.**

### Documented financial loss: itemized, not a round number

13 distinct rebate losses are documented across the three years, totaling **$27,656.85**:

| Category | Amount | Records |
|---|---|---|
| Full losses (claim fully rejected) | $13,151.90 | 5 |
| Partial write-downs (job largely succeeded, portion disallowed) | $5,984.95 | 6 |
| Unclassified (insufficient data to categorize) | $8,520.00 | 2 |

Every dollar here traces to a specific, dated, reasoned record — not an estimate. Full detail in `/data/cleaned/fact_lost_rebates.csv` and `/sql`.

### The documented loss rate climbed — and the data shows why

| Era | Documented Loss Rate |
|---|---|
| 2024 | 1.39% |
| 2025 | 2.64% |
| 2026 | 6.02% |

This runs counter to the simple "everything got better every year" story, and I'm not going to smooth that over. What the data actually shows is more specific and, I think, more useful: **9 of the 13 documented losses (69.2%) trace directly to estimator-side gaps** — missed eligibility checks, duplicate rebate claims, and incorrect job details captured at intake — not to the paperwork processing itself.

Looking at 2026 specifically, where the rate rose most: 4 of that year's 5 documented losses are estimator-attributable, and **zero are attributed to the processor** handling submissions that year. The rising rate tracks continued estimator-side errors, not a decline from consolidating PSE processing to a single person.

Two honest limits on this finding:
- 13 total records (5 in 2026) is a small sample. This is a real, itemized pattern — not a statistically proven trend.
- "Zero losses attributed to the processor" means none were *logged* as processor error in this dataset — not a confirmed clean record. It's possible earlier years (2024/2025) had losses that never made it into the tracking log at all; one documented case (a job never entered into the main tracker before it was denied) shows this kind of gap did happen at least once. The apparent size of the increase could be partly inflated by better visibility into problems now, not purely worse performance.

### Processing speed improved dramatically

| Era | Average Days, Submission to Approval |
|---|---|
| 2024 | 87.8 |
| 2025 | 46.8 |
| 2026 | 9.2 |

A ~90% reduction. No approval-date field existed anywhere in the original tracking data, so this is built from a disclosed random sample (8 jobs per era, 24 total, randomly selected and manually verified against PSE's own portal) rather than the full population — reported as a sample, not a precise population statistic.

---

## Limitations

This project is built to be checked, not just believed. Full reasoning for every judgment call — including two real corrections made mid-analysis, a duplicate record that inflated an early loss total, and a mislogged dollar amount — is in `docs/03_assumptions_and_limitations_log.md`. The short version:

- **"Documented loss," not "rejection rate."** Whether the loss log captures every denial or only the ones worth writing down hasn't been confirmed. This analysis treats it as a defensible lower bound, not an exhaustive count.
- **Real PII was found and removed** during cleaning — an exposed password, a customer name that had been typed into a dollar-amount column, and an employee named directly in a denial reason. None of that appears anywhere in this repo's data.
- **No individual employee is named or ranked anywhere in this project.** Estimators are anonymized to Estimator A–D; all cohort assignments are based on role, not identity.
- **The $100K pre-2024 figure is reported context, not a calculated result** — kept explicitly separate from the $27,656.85 figure this analysis actually itemizes.

## Connection to Operations Command Center

A separate project, [Operations Command Center](#), addresses a related but distinct problem: estimators creating job profiles in the field instead of the office, leading to incomplete data that caused downstream errors. That problem was noticed and fixed independently, after PSE was already stabilized — it wasn't planned as a follow-on to this project.

This analysis, built later, gives that earlier decision real supporting evidence: 9 of 13 documented PSE losses trace to exactly the kind of estimator-side data gaps that fix was built to catch. This dataset can't measure whether that fix worked — every job here was created in the field, so there's no office-created comparison group in this data — but it does show the underlying problem was real and had a measurable dollar cost.

Full write-up in `docs/06_cross_reference_to_estimate_accuracy_project.md`.

---

## Repository Structure

```
├── README.md                          ← this file
├── docs/
│   ├── 01_discovery_and_stakeholder_notes.md
│   ├── 02_data_profiling_notes.md
│   ├── 03_assumptions_and_limitations_log.md
│   ├── 04_business_requirements.md
│   ├── 05_data_dictionary_source_to_target_mapping.md
│   └── 06_cross_reference_to_estimate_accuracy_project.md
├── data/
│   └── cleaned/
│       ├── fact_pse_jobs.csv
│       ├── fact_lost_rebates.csv
│       └── sample_approval_times.csv
├── sql/
│   └── (one .sql file per business question, BR1–BR7)
└── dashboard/
    └── pse_recovery_dashboard.pbix
```

## Tools Used

SQL Server / T-SQL for verified analysis · Power BI for the interactive dashboard · Python for data cleaning and anonymization
