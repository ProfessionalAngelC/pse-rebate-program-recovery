# Discovery & Stakeholder Notes — PSE Rebate Program Recovery (Project 2)
**Purpose:** Establishes the business context, program history, and ground-truth operational knowledge this project is built on — gathered before any data cleaning or analysis began. This is the foundation the assumptions log, business requirements, and data dictionary all build on.

---

## 1. Program background

Puget Sound Energy (PSE) offers a rebate program for qualifying residential insulation work. The residential insulation company I work for participates in this program, which requires strict documentation, photo evidence, and paperwork compliance on a per-job basis in order for rebates to be approved and paid out.

**Program history, prior to this analysis's data:**
- Through 2023, the PSE program was managed by the accounting team, following prior years of reported significant losses. After a full year under accounting ownership, the program had still not been stabilized, and continued operating at a loss.
- In 2024, I took over ownership of the program directly. I:
  - Determined exactly what PSE required for full compliance (documentation standards, timing, photo evidence requirements)
  - Built a repeatable documentation and paperwork process from the ground up
  - Trained crew members on correct procedure, including how to photograph completed jobs to PSE's specification
  - Processed the large majority of the program's paperwork personally during this first year
- In 2025, I began training team members to take over day-to-day processing, while retaining oversight.
- In 2026, I consolidated responsibility for day-to-day processing to a single dedicated processor.

This progression — solo turnaround → team training → dedicated single processor — maps directly onto the three years of tracking data available for this analysis (2024 / 2025 / 2026), and is used as the primary time axis throughout.

---

## 2. Data landscape context

I originally structured the tracking spreadsheet used throughout this program, but once the documentation process was stable, I left day-to-day layout and column usage to the discretion of whoever was actively processing jobs. This explains why the sheet's structure (columns used, notes formatting, status tracking) shifts from year to year even though the underlying compliance requirements stayed consistent throughout. This is expected evolution of an actively-used operational tool, not inconsistent process ownership.

Two people-related fields exist in the data and represent two different roles:
- **Estimator** — the salesperson/field role that creates the initial job. Well-tracked across all three years.
- **PSE processor** — the person handling PSE paperwork submission. Only briefly and inconsistently logged (a handful of first names appear once each in the 2025 tab, corresponding to my early-2025 trainees), not usable as a structured analysis field.

---

## 3. Ground-truth clarifications established during discovery

A number of points in the raw data required direct clarification rather than assumption:

- **Cell color coding:** Customer name cells in the tracker are colored green when a job has been fully processed and paid; any other color (or no color) indicates the job did not go through for some reason. In practice, this coloring is not consistently revisited once a final outcome is known — several jobs later confirmed as denied remained colored green because the row was never revisited after submission. As a result, the separate `LOST REBATES` log — not cell color — is treated as the authoritative source for whether a rebate was ultimately denied.
- **The `LOST REBATES` tracking tab** is a log I kept of rebates that didn't go through, spanning the PSE program specifically (parallel sections for other utility programs exist on the same tab but were never populated). It's a trustworthy record of what it does contain; whether it captures every single denial that ever occurred, versus only the ones notable enough to log, isn't fully confirmed — this analysis defaults to the more conservative framing ("documented loss," not "full rejection rate") as a result.
- **Field-vs-office job creation:** every estimator on this program created job profiles from the field throughout the entire 2024–2026 period. There is no office-created comparison population in this data. A separate, later initiative (outside the scope of this program and this dataset) shifted job creation to the office — that effort is documented as its own project.
- **The $100K pre-2024 loss figure**, cited by company leadership as the scale of losses under the prior accounting-team ownership, was not independently recalculated from data I have direct access to for that period. It's retained as reported business context, not as a calculated figure in this analysis.

---

## 4. Scope decisions made during discovery

- This project covers the PSE program specifically. I've also implemented similar documentation frameworks for several other utility rebate programs (Tacoma Power, Cascade Gas, Clallam PUD, Lewis PUD, SnoPUD, Cowlitz PUD) — these are out of scope for this analysis and are only referenced briefly as evidence the framework generalized beyond PSE.
- Real customer names appear throughout the source tracking sheet. Per standard data-handling practice for a public-facing case study, these are removed entirely from any published output, regardless of the anonymization approach used for internal roles.
- No individual crew member or processor is named or ranked in any public-facing artifact from this project; all internal roles are represented by anonymized cohort labels.
