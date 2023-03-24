/*
Covid 19 Data Exploration - Bases on India

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL
ORDER BY 3,4


-- Select Data that we are going to be starting with:

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL
ORDER BY 1,2


-- 1) Total Cases vs Total Deaths -- Shows likelihood of dying if you contract covid in your country:

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%india%'
AND continent IS NOT NULL
ORDER BY 1,2


-- 2) Total Cases vs Population -- Shows what percentage of population infected with Covid:

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
order by 1,2


-- 3) Countries with the Highest Infection Rate compared to Population:

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- 4) Countries with Highest Death Count per Population:

SELECT Location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%india%'
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT 

-- 5) Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- 6) GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, (SUM(cast(new_deaths AS int))/SUM(New_Cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL
--GROUP BY date
ORDER BY 1,2



-- 7) Total Population vs Vaccinations -- Shows Percentage of Population that has recieved at least one Covid Vaccine:

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL
ORDER BY 2,3


-- 8) Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- 9) Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- 10) Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location IS NOT NULL

