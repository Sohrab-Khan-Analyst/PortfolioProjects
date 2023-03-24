SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


-- Select data we will be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths
-- Shows the Likelyhood if you contract in your Country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%india%'
ORDER BY 1,2

-- Looking at Total Cases VS Population 
-- Shows what percentage of population got covid.
SELECT location, date,  population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
ORDER BY 1,2

-- Countires with hightest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing countires with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC




SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Breaking down everthing by Continent
-- Showing continents with Highest death Count

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--- GLOBAL NUMBERS

SELECT SUM(total_cases) AS TOTALCASES, SUM(CAST (total_deaths AS int)) AS TOTALDEATHS, (SUM(CAST (total_deaths AS int))/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
where continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

-- Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.total_deaths)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 1,2,3



-- USING CTE

WITH PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/dea.total_deaths)*100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent = 'ASIA'AND dea.location = 'India' AND vac.new_vaccinations IS NOT NULL
	--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM PopVsVac


-- TEMP Table

DROP TABLE IF exists #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPeopleVaccinated
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
		AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/dea.total_deaths)*100
		FROM PortfolioProject..CovidDeaths dea
		JOIN PortfolioProject..CovidVaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent = 'ASIA'AND dea.location = 'India' AND vac.new_vaccinations IS NOT NULL
		--ORDER BY 1,2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPeopleVaccinated



-- Creating View for later Data Visualizations

CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
		AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/dea.total_deaths)*100
		FROM PortfolioProject..CovidDeaths dea
		JOIN PortfolioProject..CovidVaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent = 'ASIA'AND dea.location = 'India' AND vac.new_vaccinations IS NOT NULL
		--ORDER BY 1,2,3
