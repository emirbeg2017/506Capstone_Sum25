CREATE OR REPLACE TABLE `CapData.Capacity_Summary_11_16` AS
WITH unpivoted AS (
  SELECT
    Country,
    year_capacity_struct.year AS year,
    Technology,
    Unit,
    year_capacity_struct.capacity AS capacity
  FROM
    `CapData.Cap_Table`,
    UNNEST([
      STRUCT('2010' AS year, COALESCE(F2010, 0) AS capacity),
      STRUCT('2011', COALESCE(F2011, 0)),
      STRUCT('2012', COALESCE(F2012, 0)),
      STRUCT('2013', COALESCE(F2013, 0)),
      STRUCT('2014', COALESCE(F2014, 0)),
      STRUCT('2015', COALESCE(F2015, 0)),
      STRUCT('2016', COALESCE(F2016, 0))
    ]) AS year_capacity_struct
),

converted AS (
  SELECT
    Country,
    year,
    CASE
      WHEN Technology IN ('Hydropower (excl. Pumped Storage)', 'Solar energy', 'Wind energy', 'Bioenergy')
        THEN 'Total Renewable'
      WHEN Technology = 'Fossil fuels'
        THEN 'Total Non-Renewable'
      ELSE 'Other'
    END AS energy_type,
    capacity *
    CASE
      WHEN Unit = 'Megawatt (MW)' THEN 1
      WHEN Unit = 'Gigawatt-hours (GWh)' THEN 1000.0 / 8760.0
      ELSE 0
    END AS capacity_mw
  FROM
    unpivoted
)

SELECT
  Country,
  year,
  energy_type,
  SUM(capacity_mw) AS total_capacity_mw
FROM
  converted
WHERE
  energy_type IN ('Total Renewable', 'Total Non-Renewable')
GROUP BY
  Country, year, energy_type
ORDER BY
  Country, year, energy_type;