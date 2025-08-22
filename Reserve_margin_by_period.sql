CREATE OR REPLACE TABLE `CapData.Country_ReserveMargin_ByPeriod2` AS

SELECT
  Country,
  mean_reserve_margin,
  most_common_majority_type,
  '2010-2016' AS year_range
FROM
  `CapData.means_10_16`

UNION ALL

SELECT
  Country,
  mean_reserve_margin,
  most_common_majority_type,
  '2017-2023' AS year_range
FROM
  `CapData.means_17_23`

ORDER BY
  Country, year_range;