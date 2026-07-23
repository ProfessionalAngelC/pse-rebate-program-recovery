# Data Dictionary & Source-to-Target Mapping — PSE Rebate Program Recovery (Project 2)
**Companion to:** `01_discovery_and_stakeholder_notes.md`, `02_data_profiling_notes.md`, `03_assumptions_and_limitations_log.md`, `04_business_requirements.md`
**Purpose:** Defines the cleaned target schema this project's SQL and dashboard are built on, and exactly how each field maps back to its raw source — so every published number is traceable to a specific cell in the original file.

---

## Target schema: three tables

**`fact_pse_jobs`** — one row per job across all three tracker tabs
**`fact_lost_rebates`** — one row per distinct documented loss (13 records, after removing 1 duplicate — see §3 below)
**`sample_approval_times`** — the 24-record random sample for BR-6, populated once portal lookups are complete

---

## 1. `fact_pse_jobs`

| Target field | Source (2024 PSE) | Source (2025/2026 PSE) | Transformation |
|---|---|---|---|
| `job_id` | Column C (`Invoice # or estimate`) | Column C (`Job#`) | Cast to text (a few values are compound, e.g. `"7979 \|7984"`, or prefixed `"#8044"` — normalized to text, not numeric, to avoid data loss) |
| `era` | — | — | Derived from source tab: `2024` / `2025` / `2026` |
| `job_date` | Column B (`Date`) | Column A (`Date`) | Parsed to date; 3 known bad values fixed (§1.6 in assumptions log — one `2004` typo corrected to `2024`, two text-formatted dates parsed) |
| `submitted` | `TRUE` if Column J (`Application #`) not null | `TRUE` if Column H (`Application #`) not null | Boolean flag — this is the "submitted to PSE" definition (assumptions log §1.3) |
| `application_number` | Column J | Column H | Kept as text (some values have a stray leading space/special character) |
| `pse_amount_claimed` | Column H (`PSE Amount`) | Column G (`$ PSE Amount`) | Numeric; nulls preserved as null (not zero — a null means the field was never filled in, not that $0 was claimed) |
| `client_amount` | Column E (`Client Payment`) | Column F (`$ Client Amount`) | Numeric |
| `estimator_cohort` | Column M (`Estimator`) | Column B (`Estimator`) | **Anonymized** — see §2 below. Name variants normalized (case/whitespace) before mapping. |
| `customer_id` | Column D (`Customer`) | Column D (`Customer`) | **Dropped from public dataset**, replaced with a surrogate `CUST-####` key. Real customer names are residential PII, not just an internal-analysis nicety — excluded regardless of the employee-anonymization rules, which is a separate concern. |
| `photos_ready` | Column G (`Photos`) | Column E (`Photos`) | Normalized: `"READY"`, `"READY "`, `"READY  "` → `TRUE`; blank/null → `FALSE` |
| ~~`notes`~~ | Column N | Column K/L (misaligned, see profiling notes §2) | **Excluded entirely from the public dataset.** This field contained a live password and a denial reason naming an employee directly — free text is too inconsistent and risky to sanitize reliably at scale. Nothing analytically load-bearing was lost; no requirement in `03_business_requirements.md` depends on this field. |

---

## 2. Estimator → cohort anonymization key
*(Kept in a private, non-public mapping file — only the cohort labels ship in the public repo.)*

| Raw values (normalized) | Estimator label | Note |
|---|---|---|
| WENDY / Wendy / Wendy(+whitespace variants) | Estimator A | Appears in all three years |
| CARLOS / Carlos / Carlos F | Estimator B | Appears in all three years |
| ROB / Rob / Rob Jamison | Estimator C | Appears 2025–2026 only |
| STEVE | Estimator D | Appears 2024 only |
| Kenny | *Folded into "Other"* | Appears exactly once (2025) — a unique 1-count name would be trivially re-identifiable if given its own cohort label, so it's merged into a catch-all rather than assigned a letter |

---

## 3. `fact_lost_rebates`

| Target field | Source | Transformation |
|---|---|---|
| `loss_id` | — | Surrogate key |
| `job_id` | `Job` column, `LOST REBATES` tab (PSE section) | Join key back to `fact_pse_jobs` where possible (12 of 13 match; the Krebser record — job #6343 — has no matching row in the main tabs, retained standalone per assumptions log §1.5) |
| `loss_date` | `Date` column | **Used to assign era**, not the tab's own "PSE 2025" / "PSE 2026" section label — a few entries are mislabeled relative to their actual date (assumptions log, BR-3 methodology note) |
| `amount_lost` | `Amount` column | **Duplicate removed:** job #8029 (Saravan Natarajan) was logged twice under two different section labels with an identical amount — kept once. 13 distinct records, **$31,858.05 total** (corrected from the initial $34,178.55 / 14-record count). |
| `loss_type` | Derived | `full_loss` if `amount_lost` == the job's `pse_amount_claimed` in `fact_pse_jobs`; `partial_writedown` if less; `unknown` if no matching job row (Krebser) |
| `reason_raw` | `Reason` column | One record redacted — the Jeff Koslosky entry named an employee directly ("...Never Submitted by Dustin"); rewritten to remove the name per rule #1 |
| `reason_category` | Derived, manually coded | See breakdown below |
| `responsible_party` | Derived, manually coded, confirmed with the program owner | `estimator` (9 records — eligibility misses, duplicate claims, data-capture errors), `crew` (1 — photo documentation), `office_billing` (1 — invoicing error), `processor` (1 — missed submission, by a processor since replaced), `unrecorded` (1 — no reason logged). See assumptions log §1.12 for the reasoning behind each. |
| `estimator_cohort` | `Estimator` column (same tab) | Same anonymization key as §2 — this field is populated directly in `LOST REBATES` itself, no join required |

### Reason category breakdown (13 records)
| Category | Count | Examples |
|---|---|---|
| Eligibility rule | 5 | Remodel scope, ineligible, restoration exclusion, coverage cap, house-age requirement |
| Admin / duplicate claim | 2 | Previously claimed and adjusted, already claimed on a different rebate |
| Documentation / timing | 3 | Photos not ready before filing deadline, work not invoiced, submission never filed |
| Data-capture error | 2 | Unverified/incorrect heat source on two separate jobs — these are the two records cited in the Project 1 cross-reference (§1.8, assumptions log) |
| Unrecorded / blank reason | 1 | No reason logged — reported as-is, not guessed at |

---

## 4. `sample_approval_times` (pending — structure defined now, populated once portal data returns)

| Target field | Source | Transformation |
|---|---|---|
| `job_id` | `04_approval_date_sample_to_collect.csv` | — |
| `era` | same | — |
| `submission_date` | same (`date` column) | One known bad value (Ross Smith, job #8178 — malformed date) flagged for manual correction against the portal |
| `approval_date` | Manually collected from PSE portal | Not yet populated |
| `cycle_time_days` | Derived | `approval_date − submission_date`, computed once data returns |
| `sample_flag` | Constant `TRUE` | Every row in this table is explicitly a sample (n=24, random, seed=42) — never blended with full-population figures in the dashboard |

---

## 5. What this mapping intentionally leaves out
- `Status` column (`2024 PSE`) — superseded by the `LOST REBATES`-based outcome methodology (assumptions log §1.2); 80% null anyway
- `PSE Due Date`, `PSE Acct #` — not tied to any requirement in `03_business_requirements.md`; excluded to keep the public schema minimal rather than including fields with no analytical purpose
- Free-text notes columns — excluded per §1 above (security + anonymization risk, no offsetting analytical value)
