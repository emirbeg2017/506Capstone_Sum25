CREATE OR REPLACE TABLE `CapData.Capacity_Summary` AS
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
      STRUCT('2017' AS year, COALESCE(F2017, 0) AS capacity),
      STRUCT('2018', COALESCE(F2018, 0)),
      STRUCT('2019', COALESCE(F2019, 0)),
      STRUCT('2020', COALESCE(F2020, 0)),
      STRUCT('2021', COALESCE(F2021, 0)),
      STRUCT('2022', COALESCE(F2022, 0)),
      STRUCT('2023', COALESCE(F2023, 0))
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