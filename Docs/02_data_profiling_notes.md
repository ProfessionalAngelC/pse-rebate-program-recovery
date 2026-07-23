# Data Profiling Notes — PSE Rebate Program (Project 2)
**Source file:** Rebates_List.xlsx
**Profiled:** July 2026
**Scope confirmed:** PSE-only tabs (`2024 PSE`, `2025 PSE`, `2026 PSE`), plus the PSE section of `LOST REBATES`. Other program tabs (Tacoma Power, Cascade Gas, Clallam, Lewis PUD, PUD, SnoPUD, Cowlitz) excluded per scoping decision.

---

## 1. Workbook inventory

| Tab | In scope? | Rows w/ data | Notes |
|---|---|---|---|
| `2024 PSE` | Yes | 150 | Only tab with an explicit outcome/status field |
| `2025 PSE` | Yes | 231 | No outcome/status field — see §3 |
| `2026 PSE` | Yes | 98 | Has a `LOST` $ column; no outcome/status field |
| `LOST REBATES` | Yes (PSE section only) | 14 | Cross-tab denial/loss log; TPU and PUD sections on this same tab are empty |
| Tacoma Power, Cascade Gas, Clallam, PUD, Lewis PUD, SnoPUD, Cowlitz | No | — | Out of scope per project decision |

---

## 2. Structure per tab

### `2024 PSE`
Header row 3, columns B–N:
`Date | Invoice # or estimate | Customer | Client Payment | PSE Due Date | Photos | PSE Amount | PSE Acct # | Application # | Submitted Date | Status | Estimator | Notes`

- **This is the only tab with a `Status` field** (values: `APPROVED`, `PENDING`, `Accepted`) — but it's blank on **120 of 150 rows (80%)**.
- Date range: 2024-02 through 2024-12, with two dirty values — one row dated `2004-11-04` (almost certainly a typo for 2024) and two rows where the date is stored as text instead of a real date (`'7/31/2024'`, `"11/11/2024 '"`).
- Estimator field has case/whitespace variants: `WENDY`, `WENDY `, `WENDY  `, `STEVE`, `STEVE `, `CARLOS`, plus one `?`.

### `2025 PSE`
Header row 3, columns A–K:
`Date | Estimator | Job# | Customer | Photos | $ Client Amount | $ PSE Amount | Application # | (blank) | (blank) | Notes`

- **No outcome/status column at all.** Column L (next to the misaligned "Notes:" header) contains free-text notes, but they're inconsistent row-to-row — sometimes a name, sometimes a workflow phrase (`Working on`, `Done`, `Paid`, `PSE Approved`), sometimes a specific issue description. Rows 9–20 in that same column are actually a **floating status legend** someone typed into unused cells, not real per-row data (each phrase appears exactly once, disconnected from the adjacent job rows).
- **Found and flagging immediately: row 15's notes column contains a literal password** (`AdobePower5$`) next to the label "Adobe Password info." This needs to be deleted before the file goes anywhere near a public repo — not an anonymization nuance, just a straight security fix.
- Application # is populated on 227 of 231 rows (98%).
- Estimators: Wendy (158 combined variants), Carlos (49), Rob (22), Kenny (1 — appears nowhere else, possibly a one-off/temp).
- Date range 2023-06 through 2025-12 — the 2023 date is an outlier worth double-checking (typo, or a legitimately early job logged late?).
- Sum of `$ PSE Amount` across all rows: **$928,939.51** (this is *claimed/expected* value, not confirmed-approved — no status field to filter on).

### `2026 PSE`
Same layout as 2025, plus one addition: a `LOST` column (only populated on 3 of 98 rows, with dollar values).

- No outcome/status column here either.
- Application # populated on 87 of 98 rows (89%).
- Estimators: Wendy (57), Carlos (21), Rob (20 — including one full-name instance "Rob Jamison").
- Date range: Jan 2026 through Jul 2026 (current, partial year).
- Sum of `$ PSE Amount`: **$300,044.75** (year in progress).

### `LOST REBATES` — PSE section
This tab holds three side-by-side program logs (TPU, PUD, PSE); **only the PSE columns have any data** — TPU and PUD sections are empty. Structure: `Client | Job | Date | Amount | Reason | Estimator`, organized into two labeled blocks ("PSE 2025", "PSE 2026") that don't strictly correspond to the date of the job — a few rows under "PSE 2025" have 2024 dates.

- **14 total records**, spanning June 2024 through June 2026.
- **Sum of lost amount: $34,178.55.**
- `Reason` is free text, and it's genuinely useful — actual denial causes include things like *"Job had not been filed for and by the time it was filed for no photos existed"* (this is your exact documentation-compliance story, in the data), *"Failed to check primary heat source,"* *"Wrong heating source,"* *"Not eligible,"* *"Already claimed floor rebates,"* *"Max wall insulation amount is $5,000,"* and eligibility-type issues like *"House built in 1999."*
- **One `Reason` value names an individual employee directly:** *"Duct Seal Rebates Never Submitted by Dustin."* This is a real conflict with your rule #1 — it's not a column to anonymize, it's a sentence that needs to be rewritten/redacted during cleaning (e.g., to "rebate submission was missed by field crew" or mapped to the cohort label).
- Job # in this tab cross-references cleanly against `Job#`/`Invoice #` in the three main tabs (spot-checked: job 8029 appears in both `2026 PSE` — with a blank Application #, consistent with never having been submitted — and in `LOST REBATES`). This confirms **Job # is a reliable join key** across tabs.

---

## 3. The central gap: no consistent outcome field

This is the most important finding, and it changes how the "rejection rate" question has to be answered:

- **`2024 PSE`** has a `Status` field, but it's blank 80% of the time, and it only ever says `APPROVED`/`PENDING`/`Accepted` — **no denial-type status appears anywhere in the main tracker tabs.**
- **`2025 PSE`** and **`2026 PSE`** have no outcome field at all.
- The *only* place denials/losses are recorded is the separate `LOST REBATES` tab — 14 records total across three years.

That means the data doesn't naturally support "rejection rate = denied ÷ (denied + approved)" the way a clean CRM export would. What it *does* support, once we settle a couple of definitions with you (below), is something like: rejection rate = records in `LOST REBATES` ÷ total jobs submitted in the matching period (using Job#/Application# fill as the "submitted" population). That's workable — but it hinges on one thing I can't determine from the data itself.

---

## 4. Open questions — need your input before cleaning starts

1. **Is `LOST REBATES` a complete log of every denial, or a best-effort log of the ones that got written down?** This determines whether we can honestly call anything a "rejection rate," or whether we frame it as "documented loss events" instead — a meaningfully different (and important) framing choice.
2. **What does a blank `Status` mean in `2024 PSE`?** Not yet submitted at time of the sheet snapshot? Approved but never marked? In progress? We need a business rule to interpret 80% of that column.
3. **What are the actual training/process-change rollout date(s)?** Now that I can see the real date range (Feb 2024 – Jul 2026) and that Wendy/Steve/Carlos/Rob appear across different periods, I need your actual memory of when the new documentation process went live — and whether it was one company-wide date or rolled out crew-by-crew.
4. **Field-created vs. office-created profiles** — I don't see this tracked anywhere as an explicit field in any tab. Can you tell from anything else (e.g., which estimators always work from a truck/tablet vs. office) or is this a genuine gap we disclose as a limitation rather than guess at?

---

## 5. Immediate action items (before anonymization)

- [ ] Delete the exposed password in `2025 PSE` notes (row 15)
- [ ] Redact/rewrite the "Dustin" reference in `LOST REBATES`
- [ ] Fix the `2004` date typo and two text-formatted dates in `2024 PSE`
- [ ] Normalize estimator name variants (`WENDY`/`Wendy`/`Wendy ` → one canonical value) before mapping to cohort labels
- [ ] Confirm the `2023-06` outlier date in `2025 PSE` is legitimate or a typo
