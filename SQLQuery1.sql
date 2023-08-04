SELECT * 
FROM [dbo].[RAWDATA]



--So in summary, this is finding customers who have a short period of ordering activity - their first to most recent order is within 90 days. This may indicate customers who have churned or stopped ordering recently.

SELECT 
  name,
  COUNT(DISTINCT date) AS num_orders, 
  MIN(date) AS first_order_date,
  MAX(date) AS last_order_date
FROM [dbo].[RAWDATA]
GROUP BY name
HAVING DATEDIFF(DAY, MIN(date), MAX(date)) < 90 
ORDER BY num_orders DESC

--

-- Total Revenue Growth
SELECT
  YEAR(date) AS year,
  SUM(amount) AS total_revenue
FROM RAWDATA
WHERE date BETWEEN '2022-01-01' AND '2022-06-30' OR
      date BETWEEN '2023-01-01' AND '2023-06-30'
GROUP BY YEAR(date)

--

--
--Upsell Opportunities to identify customers buying certain products we can upsell:
--The goal of that query is to identify customers who are buying Knucle Locks, but NOT buying throwers

SELECT
  name
FROM RAWDATA
WHERE item LIKE '%knuckle lock%'
EXCEPT 
SELECT 
  name
FROM RAWDATA
WHERE item LIKE '%thrower%'

--------------------------------------------------------------
--compare total revenue growth between the first half of 2022 vs the first half of 2023 and calculate the year-over-year percentage change:
WITH revenue AS (
  SELECT 
    YEAR(date) AS year, 
    SUM(amount) AS total_revenue
  FROM RAWDATA
  WHERE date BETWEEN '2022-01-01' AND '2022-06-30'
    OR date BETWEEN '2023-01-01' AND '2023-06-30'
  GROUP BY YEAR(date)
)

SELECT
  r1.year AS previous_year,
  r1.total_revenue AS previous_revenue,
  r2.year AS current_year,
  r2.total_revenue AS current_revenue,
  (r2.total_revenue - r1.total_revenue)/r1.total_revenue AS yoy_change_pct
FROM revenue r1
JOIN revenue r2
  ON r1.year = r2.year - 1
WHERE r1.year = 2022
  AND r2.year = 2023;

  -------------------

  --Prduct segmentation + half year growth percentage
WITH segments AS (
  SELECT
    CASE  
      WHEN item IN ('5602 (Thrower Arm E30A-DI)', '5600 (Thrower Arm E30)') THEN 'Throwers'
      WHEN item LIKE '%5500 (Knuckle Lock - E42A-DI)%' THEN 'Knuckle Locks'
      WHEN item = '2505 (Brake Rod - Truck Bolster Protector Assembly)' THEN '2505'
      ELSE 'Other'
    END AS product_segment, 
    SUM(amount) AS revenue,
    date
  FROM RAWDATA
  WHERE date BETWEEN '2022-01-01' AND '2022-06-30' OR
        date BETWEEN '2023-01-01' AND '2023-06-30'
  GROUP BY
    CASE
      WHEN item IN ('5602 (Thrower Arm E30A-DI)', '5600 (Thrower Arm E30)') THEN 'Throwers'  
      WHEN item LIKE '%5500 (Knuckle Lock - E42A-DI)%' THEN 'Knuckle Locks'
      WHEN item = '2505 (Brake Rod - Truck Bolster Protector Assembly)' THEN '2505'
      ELSE 'Other'
    END, 
    date
)

SELECT
  product_segment,
  MAX(CASE WHEN YEAR(date) = 2022 THEN revenue END) AS revenue_2022,
  MAX(CASE WHEN YEAR(date) = 2023 THEN revenue END) AS revenue_2023,
  (MAX(CASE WHEN YEAR(date) = 2023 THEN revenue END) - 
   MAX(CASE WHEN YEAR(date) = 2022 THEN revenue END)) /
   MAX(CASE WHEN YEAR(date) = 2022 THEN revenue END) AS yoy_growth_pct
FROM segments
GROUP BY product_segment;

---------
--top 30 revenue from 2022 or 2023 swap WHERE DATA line
SELECT TOP 30
  name,
  SUM(amount) AS total_revenue
FROM RAWDATA
WHERE date BETWEEN '2022-01-01' AND '2022-06-30'
GROUP BY name 
ORDER BY total_revenue DESC;

----



SELECT
  name,
  SUM(CASE WHEN item LIKE '%knuckle lock%' THEN qty END) AS knuckle_locks_purchased 
FROM RAWDATA
WHERE name IN
  ('360 Rail Services', 
   'Cathcart Rail:Mountaineer Distributors',
   'Genesse & Wyoming:Buffalo & Pittsburgh Railroad', 
   'MWK RAIL, LLC',
   'MWK RAIL, LLC:MWK Mahomet',
   'Pittsburgh Pins',
   'Ronsco, Inc',
   'SCL Railway Supplies, Inc.',
   'Watco:Agawa Canyon Railroad',
   'Watco:Alabama Southern Railroad',  
   'Watco:Great Northwest Railroad',
   'Watco:Palouse River & Coulee City',
   'Watco:South Kansas & Oklahoma RR LLC',
   'Watco:Swan Ranch Railroad, LLC',
   'Watco:Vicksburg Southern RR, LLC',
   'Watco:Watco Companies, LLC',
   'Watco:Watco Mechanical Services')
GROUP BY name
ORDER BY knuckle_locks_purchased DESC;

SELECT
  name,
  SUM(CASE WHEN item LIKE '%knuckle lock%' THEN amount END) AS knuckle_lock_revenue
FROM RAWDATA  
WHERE name IN
  ('360 Rail Services',
  'Cathcart Rail:Mountaineer Distributors',  
  'Genesse & Wyoming:Buffalo & Pittsburgh Railroad',
  'MWK RAIL, LLC',
  'MWK RAIL, LLC:MWK Mahomet',
  'Pittsburgh Pins',
  'Ronsco, Inc',
  'SCL Railway Supplies, Inc.',
  'Watco:Agawa Canyon Railroad',
  'Watco:Alabama Southern Railroad',   
  'Watco:Great Northwest Railroad',
  'Watco:Palouse River & Coulee City',
  'Watco:South Kansas & Oklahoma RR LLC',
  'Watco:Swan Ranch Railroad, LLC',
  'Watco:Vicksburg Southern RR, LLC',
  'Watco:Watco Companies, LLC',
  'Watco:Watco Mechanical Services')
GROUP BY name  
ORDER BY knuckle_lock_revenue DESC;


SELECT
  name,
  SUM(CASE WHEN item LIKE '%knuckle lock%' THEN amount END) AS knuckle_lock_revenue  
FROM RAWDATA
WHERE name IN
  ('Cathcart Rail:Mountaineer Distributors',
   'Chicago South Shore and South Bend Railro', 
   'Comet Industries.',
   'CSX Transportation',
   'DIMEC:Dimec - Moon Township',
   'DW Supply Group',
   'Genesse & Wyoming:Buffalo & Pittsburgh Railroad',
   'Genesse & Wyoming:Portland & Western Railroad',
   'Illini Castings', 
   'MWK RAIL, LLC',
   'Pittsburgh Pins',
   'Rocky Mountain Railcar Repair, Inc.',
   'Ronsco, Inc',
   'SCL Railway Supplies, Inc.',
   'Union Pacific Railroad',
   'Watco:Agawa Canyon Railroad',
   'Watco:Alabama Southern Railroad',
   'Watco:Decatur & Eastern Illinois RR, LLC',
   'Watco:Eastern Idaho Railroad, LLC',
   'Watco:Great Northwest Railroad',
   'Watco:Swan Ranch Railroad, LLC',
   'Watco:Vicksburg Southern RR, LLC',
   'Watco:Watco Companies, LLC',
   'Watco:Watco Mechanical Services',
   'Watco:Wisconsin & Southern Railroad Co')
GROUP BY name
ORDER BY knuckle_lock_revenue DESC;

SELECT
  name,
  SUM(CASE WHEN item LIKE '%thrower%' THEN amount END) AS thrower_revenue
FROM RAWDATA
WHERE name IN
  ('AITX Railcar Services LLC:AITX Railcar Service of Canada', 
   'American Industries',
   'Burlington Northern Santa Fe',
   'Carly Railcar Components, LLC',
   'Economy Coating Systems',
   'Finger Lakes Railway',
   'Genesse & Wyoming:Ottawa Valley Railway',
   'Genesse & Wyoming:Rochester & Southern RR',
   'Pennsy',
   'RJ Corman',
   'RJ Corman:RJ Corman Nicholasville',
   'RJ Corman:RJ Corman Switching Company',  
   'Terminal Railway',
   'Watco:Austin Western Railroad LLC:Grand Elk Railroad',
   'Watco:Blue Ridge Southern LLC',
   'Watco:Boise Valley Railroad, LLC',
   'Watco:Fox Valley Lake Superior',
   'Watco:Lubbock & Western, Railway, LLC',
   'Watco:Millenium Rail LLC')
GROUP BY name
ORDER BY thrower_revenue DESC;

SELECT
  name, 
  SUM(CASE WHEN item LIKE '%thrower%' THEN amount END) AS thrower_revenue
FROM RAWDATA
WHERE name IN
  ('AITX Railcar Service of Canada Inc',
   'American Industries', 
   'Burlington Northern Santa Fe',
   'Carly Railcar Components, LLC',
   'Cathcart Rail:Appalachian Railcar Services',
   'Genesse & Wyoming',
   'Genesse & Wyoming:Ottawa Valley Railway',
   'Genesse & Wyoming:Portland & Western Railroad',
   'Genesse & Wyoming:Rochester & Southern RR',
   'Illini Castings',
   'Jaguar Transport',
   'Pennsy',
   'Rocky Mountain Railcar Repair, Inc.',
   'Terminal Railway',
   'Terminal Railway- Alabama Port Authority',
   'Union Pacific Railroad',
   'Watco:Ann Arbor Railroad',
   'Watco:Austin Western Railroad LLC:Grand Elk Railroad', 
   'Watco:Birmingham Terminal Railroad Co',
   'Watco:Blue Ridge Southern LLC',
   'Watco:Decatur & Eastern Illinois RR, LLC',
   'Watco:Eastern Idaho Railroad, LLC',
   'Watco:Fox Valley Lake Superior',
   'Watco:Ithaca Central Railroad, L.L.C.',
   'Watco:Kanawha River RR',
   'Watco:Lubbock & Western, Railway, LLC',
   'Watco:Stillwater Central Railroad',
   'Watco:Wisconsin & Southern Railroad Co')
GROUP BY name
ORDER BY thrower_revenue DESC;

SELECT
  name,
  SUM(CASE WHEN item LIKE '%5400 (C-10 Knuckle Pin)%' THEN amount END) AS Pin_revenue
FROM RAWDATA
WHERE name IN
 
GROUP BY name
ORDER BY thrower_revenue DESC;



SELECT
  name,
  SUM(CASE WHEN item LIKE '%5400 (C-10 Knuckle Pin)%' THEN amount END) AS pin_revenue
FROM RAWDATA
WHERE name IN
  ('AITX Railcar Services LLC:AITX Railcar Service of Canada',
   'Arkansas & Missouri RR Co', 
   'Conrad Yelvington:Preferred Materials, Inc.',
   'Coos Bay Rail link',
   'DIMEC',
   'D''s Kustom Sales & Service LLC',
   'Economy Coating Systems',
   'Finger Lakes Railway',
   'Florida East Coast Railway Co',
   'GATX',
   'Inter-Rail Management, Inc.',
   'Inter-Rail Transport',
   'JMA Rail Products',
   'MWK RAIL, LLC:MWK Mahomet',
   'Northwest Railcar',
   'RJ Corman',
   'RJ Corman:RJ Corman Blue Springs',
   'RJ Corman:RJ Corman Nicholasville',
   'RJ Corman:RJ Corman Switching Company',
   'Road & Rail Services',
   'Rocky Mountail Railcar-Tooele',
   'Southeastern Railway Services',
   'Titan Transportation',
   'Titan Transportation old', 
   'Titan Transportation:RCS Transportation',
   'Traditional Logistics and Cartage',
   'Traditional Logistics and Cartage old',
   'Transco Railway Products:Transco  P.O. Box 4031',
   'Transportation Services:TSI - 31046',
   'Transportation Services:TSI 35062',
   'Transportation Services:TSI PO Box 1107',
   'Transportation Services:TSI PO Box 217',
   'Transportation Services:TSI PO Box 479',
   'Transportation Services:TSI PO Box 85',
   'Watco:Boise Valley Railroad, LLC',
   'Watco:Millenium Rail LLC')  
GROUP BY name
ORDER BY pin_revenue DESC;

SELECT
  name,
  SUM(CASE WHEN item LIKE '%5400 (C-10 Knuckle Pin)%' THEN amount END) AS pin_revenue
FROM RAWDATA
WHERE name IN
  ('AITX Railcar Services LLC:AITX Railcar Service of Canada',
   'Arkansas & Missouri RR Co',
   'Chicago South Shore and South Bend Railro',
   'Comet Industries.',
   'Conrad Yelvington:Preferred Materials, Inc.',
   'Coos Bay Rail link',
   'DIMEC',
   'DIMEC:Dimec - Moon Township',
   'D''s Kustom Sales & Service LLC',
   'DW Supply Group',
   'Finger Lakes Railway', 
   'Florida East Coast Railway Co',
   'GATX',
   'Genesse & Wyoming:Buffalo & Pittsburgh Railroad',
   'Inter-Rail Management, Inc.',
   'Inter-Rail Transport',  
   'JMA Rail Products',
   'MWK RAIL, LLC',
   'MWK RAIL, LLC:MWK Mahomet',
   'Northwest Railcar',
   'RJ Corman',
   'RJ Corman:RJ Corman Nicholasville',
   'Road & Rail Services',
   'Southeastern Railway Services',
   'Titan Transportation old',
   'Titan Transportation:RCS Transportation',
   'Traditional Logistics and Cartage',
   'Transco Railway Products:Transco  P.O. Box 4031',
   'Transportation Services:TSI - 31046',
   'Transportation Services:TSI 35062',
   'Transportation Services:TSI PO Box 1107',
   'Transportation Services:TSI PO Box 217',
   'Transportation Services:TSI PO Box 479',
   'Transportation Services:TSI PO Box 85',  
   'Watco:Boise Valley Railroad, LLC',
   'Watco:Millenium Rail LLC',
   'Watco:Watco Companies, LLC',
   'Watco:Watco Mechanical Services')
GROUP BY name  
ORDER BY pin_revenue DESC;

SELECT
  name,
  SUM(CASE WHEN item LIKE '%5400 (C-10 Knuckle Pin)%' THEN amount END) AS pin_revenue
FROM RAWDATA
WHERE name IN
  ('Arkansas & Missouri RR Co',
   'Conrad Yelvington:Preferred Materials, Inc.',
   'Coos Bay Rail link',
   'DIMEC', 
   'D''s Kustom Sales & Service LLC',
   'Florida East Coast Railway Co',
   'GATX',
   'Genesse & Wyoming:Buffalo & Pittsburgh Railroad',
   'Inter-Rail Management, Inc.',
   'Inter-Rail Transport',
   'JMA Rail Products',
   'MWK RAIL, LLC',
   'MWK RAIL, LLC:MWK Mahomet',
   'Northwest Railcar',
   'RJ Corman:RJ Corman Blue Springs',
   'Road & Rail Services',
   'Rocky Mountail Railcar-Tooele',
   'Southeastern Railway Services',
   'Titan Transportation',
   'Titan Transportation old',
   'Titan Transportation:RCS Transportation', 
   'Traditional Logistics and Cartage',
   'Traditional Logistics and Cartage old',
   'Transco Railway Products:Transco  P.O. Box 4031',
   'Transportation Services:TSI - 31046',
   'Transportation Services:TSI 35062',
   'Transportation Services:TSI PO Box 1107',
   'Transportation Services:TSI PO Box 217',
   'Transportation Services:TSI PO Box 479',
   'Transportation Services:TSI PO Box 85',
   'Watco:Watco Companies, LLC',
   'Watco:Watco Mechanical Services')
GROUP BY name
ORDER BY pin_revenue DESC;


SELECT
  name,
  SUM(CASE WHEN item LIKE '%5300 (Lock Lift E24B)%' THEN amount END) AS locklift_revenue
FROM RAWDATA
WHERE name IN (
  'AITX Railcar Service of Canada Inc',
  'American Industries',
  'Burlington Northern Santa Fe',
  'Cathcart Rail:Appalachian Railcar Services',
  'Genesse & Wyoming',
  'Jaguar Transport',
  'Metro East Industries',
  'Terminal Railway',
  'Terminal Railway- Alabama Port Authority',
  'Watco:Ann Arbor Railroad',
  'Watco:Austin Western Railroad LLC:Grand Elk Railroad',
  'Watco:Birmingham Terminal Railroad Co',
  'Watco:Elwood & Joliet Southern',
  'Watco:Ithaca Central Railroad, L.L.C.',
  'Watco:Kanawha River RR',
  'Watco:Kansas & Oklahoma RR LLC',
  'Watco:Lubbock & Western, Railway, LLC',
  'Watco:Palouse River & Coulee City',
  'Watco:South Kansas & Oklahoma RR LLC',
  'Watco:Stillwater Central Railroad'
)
GROUP BY name
ORDER BY locklift_revenue DESC;


SELECT
  name,
  SUM(CASE WHEN item LIKE '2772.17.0 (Centerbeam Cable - 17ft)%' THEN amount END) AS cable_revenue
FROM RAWDATA
WHERE name = 'Terminal Railway:Terminal Rail Association of St. Louis'
GROUP BY name
ORDER BY cable_revenue DESC;
