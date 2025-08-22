CREATE OR REPLACE TABLE `CapData.Demand_Summary` AS
SELECT 
  Area,
  year,
  (Value * 1000000) / 8760 AS value_mw
FROM 
  `CapData.Demand`
WHERE 
  year > 2016;