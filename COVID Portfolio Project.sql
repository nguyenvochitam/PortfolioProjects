SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract in your country

SELECT location, date, total_cases, total_deaths, 
       CASE 
           WHEN total_cases = 0 THEN 0 
           ELSE (total_deaths / total_cases) * 100 
       END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%VIET%' AND continent is not null
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, 
       CASE 
           WHEN population = 0 THEN 0 
           ELSE (total_cases / population) * 100 
       END AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%VIET%'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, 
       MAX(total_cases) as HighestInfectionCount, 
       MAX(CASE 
               WHEN population = 0 THEN 0 
               ELSE (total_cases / population) * 100 
           END) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing Coutries with Highest Death Count oer Population 

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%VIET%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing continents with the highest death count per population 
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%VIET%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, 
       SUM(new_deaths) as total_deaths, 
       CASE 
           WHEN SUM(new_cases) = 0 THEN 0 
           ELSE (SUM(new_deaths) / SUM(new_cases)) * 100 
       END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations

-- USE CTE 
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS 
(
    SELECT 
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        v.new_vaccinations, 
        SUM(CONVERT(BIGINT, ISNULL(v.new_vaccinations, 0))) 
        OVER (PARTITION BY d.location ORDER BY d.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths d
    JOIN PortfolioProject..CovidVaccinations v
        ON d.location = v.location
        AND d.date = v.date
    WHERE d.continent IS NOT NULL
)
SELECT *
FROM PopvsVac;

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        v.new_vaccinations, 
        SUM(CONVERT(BIGINT, ISNULL(v.new_vaccinations, 0))) 
        OVER (PARTITION BY d.location ORDER BY d.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
    FROM PortfolioProject..CovidDeaths d
    JOIN PortfolioProject..CovidVaccinations v
        ON d.location = v.location
        AND d.date = v.date
    --WHERE d.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        v.new_vaccinations, 
        SUM(CONVERT(BIGINT, ISNULL(v.new_vaccinations, 0))) 
        OVER (PARTITION BY d.location ORDER BY d.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
    FROM PortfolioProject..CovidDeaths d
    JOIN PortfolioProject..CovidVaccinations v
        ON d.location = v.location
        AND d.date = v.date
    WHERE d.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

 


