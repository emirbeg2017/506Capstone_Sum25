CREATE OR REPLACE TABLE `CapData.F_table_10_16` AS
WITH renewable_totals AS (
  SELECT
    Country,
    year,
    SUM(total_capacity_mw) AS total_renewable_mw
  FROM
    `CapData.Capacity_Summary_11_16`
  WHERE
    energy_type = 'Total Renewable'
  GROUP BY
    Country, year
),
nonrenewable_totals AS (
  SELECT
    Country,
    year,
    SUM(total_capacity_mw) AS total_nonrenewable_mw
  FROM
    `CapData.Capacity_Summary_11_16`
  WHERE
    energy_type = 'Total Non-Renewable'
  GROUP BY
    Country, year
),
capacity_totals AS (
  SELECT
    Country,
    year,
    SUM(total_capacity_mw) AS total_capacity_mw
  FROM
    `CapData.Capacity_Summary_11_16`
  GROUP BY
    Country, year
),
demand_totals AS (
  SELECT 
    Area AS Country,
    year,
    (Value * 1000000) / 8760 AS total_demand_mw
  FROM 
    `CapData.Demand`
  WHERE 
    year > 2009
)
SELECT
  d.Country,
  d.year,
  (c.total_capacity_mw - d.total_demand_mw) AS reserve_margin_mw,
  CASE
    WHEN r.total_renewable_mw > n.total_nonrenewable_mw THEN 'Majority Renewable'
    WHEN n.total_nonrenewable_mw > r.total_renewable_mw THEN 'Majority Non-Renewable'
    ELSE 'Equal Split'
  END AS majority_type
FROM
  demand_totals d
INNER JOIN
  capacity_totals c
    ON d.Country = c.Country
    AND CAST(d.year AS INT64) = CAST(c.year AS INT64)
LEFT JOIN
  renewable_totals r
    ON d.Country = r.Country
    AND CAST(d.year AS INT64) = CAST(r.year AS INT64)
LEFT JOIN
  nonrenewable_totals n
    ON d.Country = n.Country
    AND CAST(d.year AS INT64) = CAST(n.year AS INT64)
ORDER BY
  d.Country ASC,
  d.year ASC;