# SOCI_quant_502

## Data

Raw CCC protest data are in `data/raw/ccc/`, downloaded from the CCC website https://dataverse.harvard.edu/dataverse/crowdcountingconsortium/:

- `ccc_compiled_20172020.csv`
- `ccc_compiled_20212024.csv.gz` (gzipped because the original was over GitHub's 100 MB limit)
- `ccc-phase3-public.csv` (2025, as available at download)

## Cleaning and definitions

- The three CCC phases name the topic column differently, so they were combined into one `topic` column.
- Events with no topic (~2.4%) were dropped. Only "environment" or "climate" events were kept, then counted per month.
- A **protest wave** is a month in the top 10% of monthly counts (an arbitrary cutoff; sensitivity tests are a next step).
- The study window runs from December 2017 to the last full month of CCC data.
- A few extreme outlier months remain unresolved. The heat map colour scale is capped at 350 so the other months stay readable.