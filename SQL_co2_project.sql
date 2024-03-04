--Lets start checking whether queries work 
SELECT *
FROM portfolio_project..owid_pop_gdp$
ORDER BY 1,2

SELECT * 
FROM portfolio_project..owid_co2$
ORDER BY 1,2

-- Checking nulls in key columns before joining two tables
SELECT *
FROM portfolio_project..owid_pop_gdp$
WHERE country IS NULL or year IS NULL

SELECT *
FROM portfolio_project..owid_co2$
WHERE co2 IS NULL or year IS NULL


-- Checking for dubplicates and the number of countries in the both tables
SELECT
 DISTINCT country
FROM portfolio_project..owid_pop_gdp$
ORDER BY country ASC

SELECT COUNT(DISTINCT country) AS number_of_countries_pop
FROM portfolio_project..owid_pop_gdp$

SELECT 
 DISTINCT country
FROM portfolio_project..owid_co2$
ORDER BY country ASC

SELECT COUNT(DISTINCT country) AS number_of_countries_co2
FROM portfolio_project..owid_co2$


-- Joining tables using join function
SELECT *
FROM owid_pop_gdp$ g
JOIN owid_co2$ c 
   ON g.country = c.country 
   AND g.year = c.year
ORDER BY 1,2 
 
--Now lets create new colummns based on calculations using population, gdp and co2
--These new values will show co2 per capita and co2 per gdp. Lets take United States as an example 
Select g.country, g.year, g.iso_code, g.population, c.co2, (c.co2*1000000/g.population) AS co2_per_capita, 
   (c.co2*1000000/g.gdp*1000) as co2_per_gdp
FROM owid_pop_gdp$ g
JOIN owid_co2$ c 
   ON g.country = c.country 
   AND g.year = c.year
WHERE g.iso_code is not null
      and gdp <> 0
	  and g.country like '%states'
ORDER BY 1,2 

-- Similiralry, lets create new columns showing consumption of co2 and per capita and per gdp
SELECT g.country, g.year, g.iso_code, g.population, c.consumption_co2, 
      (c.consumption_co2*1000000/g.population) AS cons_co2_per_capita, 
	  (c.consumption_co2*1000000/g.gdp*1000) AS cons_co2_per_gdp
FROM owid_pop_gdp$ g
JOIN owid_co2$ c 
   ON g.country = c.country 
   AND g.year = c.year
WHERE g.iso_code is not null
   AND gdp <> 0
   AND g.country like '%states%'
ORDER BY 1,2 

--Now lets be more precise and find ound top 20 co2 emitter countries based on emissions per capita in 2022
SELECT TOP 20 g.country, g.year, g.iso_code,
   CASE 
     WHEN g.population = 0 THEN NULL  -- Division by zero, return NULL
     ELSE (c.co2 * 1000000 / NULLIF(g.population, 0))  -- Prevent division by zero
    END AS co2_per_capita
FROM 
   owid_pop_gdp$ g
JOIN owid_co2$ c 
   ON g.country = c.country 
   AND g.year = c.year
WHERE 
   g.iso_code IS NOT NULL
   AND g.year = 2021
ORDER BY 
  co2_per_capita DESC;


--Now lets be more precise and find ound top 20 co2 emitter countries based on emissions per capita in 2022
SELECT TOP 20 g.country, g.year, g.iso_code,
   CASE 
     WHEN g.gdp = 0 THEN 0  -- If GDP is zero, set co2_per_gdp to zero
     ELSE (c.co2 * 1000000/g.gdp)
    END AS co2_per_gdp
From owid_pop_gdp$ g
JOIN owid_co2$ c 
   ON g.country = c.country 
   AND g.year = c.year
Where 
   g.iso_code IS NOT NULL
   AND g.year = 2018 
   AND g.gdp IS NOT NULL
   AND g.gdp <> 0
Order by 
  co2_per_gdp DESC;

--Finally, lets break cumulative CO2 emissions by continents 
SELECT country, SUM(co2) as cumulative_co2_cont
FROM 
 owid_co2$
WHERE 
 country IN ('Asia', 'Africa', 'Oceania', 'Europe', 'North America', 'South America')
GROUP BY country
ORDER BY cumulative_co2_cont DESC;
 