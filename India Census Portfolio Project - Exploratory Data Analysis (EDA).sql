
--============================================================================--
--						
-- Indian Population Census Project || Exploratory Data Analysis (EDA) --
--						
--============================================================================--


	-- Ques 1: Number of Rows in our DataSets - 

SELECT COUNT(*) AS D1
FROM CensusProject..Dataset1

SELECT COUNT(*) AS D2
FROM CensusProject.dbo.Dataset2

	-- Ques 2: Generate data for only 'N' Number of states only - 

SELECT *
FROM CensusProject..DataSet1
WHERE State in ('Madhya Pradesh', 'Jharkand', 'Bihar')

	-- Ques 3: Calculate the total Population of India -

SELECT SUM(Population) AS Total_Population 
FROM CensusProject..Dataset2

	-- Ques 4: Calculate the Total Growth (in %) of India -

SELECT AVG(Growth) * 100 AS Total_Growth
FROM CensusProject.dbo.Dataset1

	-- Ques 5: Calculate the Average Growth (in %) by the State -
		-- ALso, order the results from Largest to Smallest.

SELECT State,
       FORMAT(AVG(Growth) * 100, 'N2') + '%' AS Avg_Growth
FROM CensusProject.dbo.Dataset1
GROUP BY State
ORDER BY Avg_Growth DESC;


	-- Ques 6: Calculate the Average Sex_Ratio (round to 0) by the State -
		-- ALso, order the results from Highest to Lowest.

SELECT State, ROUND(AVG(Sex_Ratio),0) Avg_Sex_Growth
FROM CensusProject..Dataset1
GROUP BY State
ORDER BY Avg_Sex_Growth DESC;


	-- Ques 7: Calculate the Average Literacy Rate (round to 0) by the State -
		-- Ordered the results from Highest to Lowest.
			-- Only Showing Literacy Rate above 60.

SELECT State, ROUND(AVG(Literacy), 0) Avg_Literacy
FROM CensusProject..Dataset1
GROUP BY State
HAVING ROUND(AVG(Literacy), 0) > 70
ORDER BY Avg_Literacy DESC;


	-- Ques 8:What are the Top 5 States with the Highest Growth Rate - 

SELECT TOP 5 State, ROUND((AVG(Growth) * 100), 2) Avg_Growth
FROM CensusProject..Dataset1
GROUP BY State
ORDER BY Avg_Growth DESC;


	-- Ques 8:What are the Top 5 States with the Lowest Sex Rate - 

SELECT TOP 5 State, ROUND(AVG(Sex_Ratio), 2) Avg_Sex_Growth
FROM CensusProject..Dataset1
GROUP BY State
ORDER BY Avg_Sex_Growth;


	-- Ques 9: Displaying the Top 5 & Bottom 5 States in  Literacy Rate - 

		-- For Top 5 States --

DROP TABLE IF EXISTS #TopStates;
CREATE TABLE #TopStates (
	state nvarchar(255),
	topstates float
	)

INSERT INTO #TopStates
SELECT State, ROUND(AVG(Literacy), 0) Avg_Literacy_Rate
FROM CensusProject..Dataset1
GROUP BY State
ORDER BY Avg_Literacy_Rate DESC;

SELECT TOP 5 *
FROM #TopStates
ORDER BY #TopStates.topstates DESC;


		-- For Bottom 5 States --

DROP TABLE IF EXISTS #BottomStates;
CREATE TABLE #BottomStates (
	state nvarchar(255),
	bottomstates float
	)

INSERT INTO #BottomStates
SELECT State, ROUND(AVG(Literacy), 0) Avg_Literacy_Rate
FROM CensusProject..Dataset1
GROUP BY State
ORDER BY Avg_Literacy_Rate;

SELECT TOP 5 *
FROM #BottomStates
ORDER BY #BottomStates.bottomstates;

		-- Now, combining the #TopStates & #BottomStates tables --
			-- Using UNION Operator --

SELECT *
FROM (
	SELECT TOP 5 *
	FROM #TopStates
	ORDER BY #TopStates.topstates DESC) A

UNION

SELECT *
FROM (
	SELECT TOP 5 *
	FROM #BottomStates
	ORDER BY #BottomStates.bottomstates) B


	-- Ques 10: If wanted to Filter all the States - 

		-- 10.1 Starting with letter 'A' or 'B' - 

SELECT DISTINCT State
FROM CensusProject..Dataset1
WHERE LOWER(State) like 'a%' OR LOWER(State) like 'b%'

		-- 10.2 Starting with letter 'A' or ending with letter 'D' - 

SELECT DISTINCT State
FROM CensusProject..Dataset1
WHERE LOWER(State) like 'a%' OR LOWER(State) like '%d'



	-- Ques 11: Joining the 2 DataSets using 'Inner Join' using the shared District column -

SELECT DISTINCT D1.State, D1.District , D1.Growth, D1.Sex_Ratio
			, D1.Literacy, D2.Population, D2.Area_km2
FROM CensusProject..Dataset1 D1
INNER JOIN CensusProject..Dataset2 D2
ON D1.District = D2.District
-- WHERE D1.State = 'Madhya Pradesh' AND D1.District = 'Bhopal' -- 
ORDER BY D2.Population ASC;


	-- Ques 12: Now, using the Joined table, Calculate the Total Number of Males & Females in a State -
			-- Using the following formulas: (1) Number of Males = Population * (Sex Ratio / 1000).
			--								 (2) Number of Females = Population - Number of Males.

SELECT DISTINCT D1.State, D1.District , D1.Growth, D1.Sex_Ratio
		, D1.Literacy, D2.Population, D2.Area_km2
		, ROUND((D1.Sex_Ratio/1000) * D2.Population, 0) AS Num_of_Males
		, ROUND(D2.Population - (D2.Population * (D1.Sex_Ratio/1000)), 0) AS Num_of_Females
FROM CensusProject..Dataset1 D1
INNER JOIN CensusProject..Dataset2 D2
ON D1.District = D2.District
ORDER BY D2.Population DESC;

	-- Ques 13: Calculate Total Number of Males & Females in  the Population -
		--  Using the Calculated fields of "Num_of_Males" & "Num_of_Females".

SELECT SUM(Num_of_Males) AS Total_Males,
       SUM(Num_of_Females) AS Total_Females
FROM (
    SELECT DISTINCT D1.State, D1.District , D1.Growth, D1.Sex_Ratio
		, D1.Literacy, D2.Population, D2.Area_km2
		, ROUND((D1.Sex_Ratio/1000) * D2.Population, 0) AS Num_of_Males
		, ROUND(D2.Population - (D2.Population * (D1.Sex_Ratio/1000)), 0) AS Num_of_Females
	FROM CensusProject..Dataset1 D1
	INNER JOIN CensusProject..Dataset2 D2
	ON D1.District = D2.District
) AS Subquery;



	-- Ques 14: Calculate the Total Literacy Rate of the Population, (Also, shown in Percentage) -
			--   The "Total Literacy Rate" represents the overall literacy rate across a population
			-- , considering the literacy rate of each region (state, district, etc.) and their respective populations. 


SELECT SUM(Total_Literacy) / SUM(Population) AS Total_Literacy_Rate
       , FORMAT(SUM(Total_Literacy) / SUM(Population), 'P') AS Total_Literacy_Rate_Percentage
FROM (
    SELECT DISTINCT D1.State, D1.District, D1.Literacy, D2.Population, D1.Growth
          , (D2.Population * D1.Literacy) / 100 AS Total_Literacy
    FROM CensusProject..Dataset1 D1
    INNER JOIN CensusProject..Dataset2 D2 ON D1.District = D2.District
) AS Subquery;


	-- Ques 15: Calculate the  Weighted Literacy Rate of the Each District, (Also, shown in Percentage) -
		-- The "Weighted Literacy Rate" with growth rate takes into account not only the literacy rate of each region
		-- , but also considers the growth rate of each region's population.


SELECT DISTINCT D1.State, D1.District, D1.Literacy, D2.Population, D1.Growth
      , ROUND(((D2.Population * D1.Literacy * D1.Growth) / 100),0) AS Weighted_Literacy_Rate
      , FORMAT(((D2.Population * D1.Literacy * D1.Growth) / 100) / D2.Population, 'P') AS Weighted_Literacy_Rate_Percentage
FROM CensusProject..Dataset1 D1
INNER JOIN CensusProject..Dataset2 D2 ON D1.District = D2.District
ORDER BY Weighted_Literacy_Rate_Percentage DESC;


	-- Ques 15: Calculate the Population of the Each District during the previous Census -
		-- Using the following formulas: (1) Previous Population = Current Population / (1 + Growth Rate/100).


SELECT DISTINCT D1.State, D1.District, D1.Growth
		, D2.Population AS Current_Population
		, ROUND((D2.Population / ((1 + (D1.Growth)/100))), 0) AS Previous_Population
FROM CensusProject..Dataset1 D1
INNER JOIN CensusProject..Dataset2 D2 
ON D1.District = D2.District
ORDER BY Previous_Population DESC;

	-- Ques 16: Calculating how much District Area is reducing as Population Increases - 

SELECT 
    D1.State, D1.District, D1.Growth, D1.Sex_Ratio, D1.Literacy
    , D2.Area_km2, D2.Population
    , ROUND((D2.Population / (1 + (D1.Growth) / 100)), 0) AS Previous_Population
    , FORMAT(D2.Area_km2 - (D2.Population * (D2.Area_km2 / D2.Population)), 'P') AS Reduced_Area
FROM CensusProject..Dataset1 D1
INNER JOIN CensusProject..Dataset2 D2 ON D1.District = D2.District
ORDER BY Reduced_Area DESC;

		-- Conclusion:  Change in population has not substantially affected the area size.



--============================================================================--
--								   END
--								THANK YOU
--============================================================================--
