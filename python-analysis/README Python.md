# Python Analysis — Other Utility Rebate Programs

A hands-on pandas notebook cleaning and combining real tracking data across 7 smaller utility rebate programs — a complement to the main SQL/Power BI analysis of the PSE program in this repo.

## Why this exists

The main README notes that the documentation framework built for PSE was later adapted to other utility programs (Tacoma Power, Cascade Gas, Clallam PUD, Lewis PUD, SnoPUD, Cowlitz PUD). This notebook makes that claim concrete and verifiable, using the real tracking data for those programs.

It also demonstrates a different part of the toolchain than the rest of this repo — direct, hands-on Python/pandas work, rather than SQL or Power BI.

## What's in this notebook

- Loading 9 separate spreadsheet tabs, each with inconsistent column names, typos, and structure
- Standardizing column names across tabs, fixing typos, removing empty/junk columns found along the way
- Extracting a structured status field from a multi-stage approval process (one program tracked approval as 4 separate Yes/No columns instead of a single status)
- Repairing and validating malformed dates
- Combining all 9 tabs into one clean, 38-record dataset
- Verifying zero duplicate records after combining
- Anonymizing individual names to the same cohort labels (Estimator A/B/C) used in the main PSE analysis
- Summary aggregations and a visualization of rebate value by program and by estimator

## Key finding

**$167,514.55** in combined rebate value across the 7 programs, with the PUD program contributing the largest share ($91,183.00).

## Files

- `other_utility_programs_analysis.ipynb` — the full notebook, code and output together
- `other_utility_programs_cleaned.csv` — the final cleaned, anonymized dataset
