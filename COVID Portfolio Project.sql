SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at total cases vs total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/Total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states'
ORDER BY 1,2


-- Looking at total cases vs the population
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population 
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Population, location
ORDER BY PercentPopulationInfected DESC


-- Looking at countries with highest death rate compared to population 
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continent (Correct data)
-- Showing the continents with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continent (Option 2 for future use)
-- Showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers by date
SELECT date, SUM(new_cases) as Total_cases, SUM(cast(New_deaths as int)) as TotalDeaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentageWorld
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Global numbers
SELECT SUM(new_cases) as Total_cases, SUM(cast(New_deaths as int)) as TotalDeaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentageWorld
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at total population vs vaccinations
-- Join tables Deaths and vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated)/population*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--CAST as .. or Convert(..,


-- USE CTE
WITH PopvsVac (Continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated)/population*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/Population)*100 
FROM PopvsVac
ORDER BY 2,3


--TEMP TABLE
DROP Table if exists #percentPopulationVaccinated
CREATE TABLE #percentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

INSERT INTO #percentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated)/population*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


SELECT *,(RollingPeopleVaccinated/Population)*100 
FROM #percentPopulationVaccinated
ORDER BY 2,3


-- Creating view to store data for later visualisations
CREATE View percentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated)/population*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



