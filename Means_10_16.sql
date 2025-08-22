CREATE OR REPLACE TABLE `CapData.means_10_16` AS
WITH majority_counts AS (
  SELECT
    Country,
    majority_type,
    COUNT(*) AS type_count
  FROM `CapData.F_table_10_16`
  GROUP BY Country, majority_type
),

ranked_majority AS (
  SELECT
    Country,
    majority_type,
    type_count,
    ROW_NUMBER() OVER (PARTITION BY Country ORDER BY type_count DESC, majority_type) AS rn
  FROM majority_counts
)

SELECT
  t.Country,
  AVG(t.reserve_margin_mw) AS mean_reserve_margin,
  r.majority_type AS most_common_majority_type
FROM `CapData.F_table_10_16` t
JOIN ranked_majority r
  ON t.Country = r.Country AND r.rn = 1
GROUP BY t.Country, r.majority_type
ORDER BY t.Country;