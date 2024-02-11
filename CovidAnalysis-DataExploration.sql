SELECT * FROM CovidAnalysis..CovidDeaths
SELECT * FROM CovidAnalysis..CovidVaccinations

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidAnalysis..CovidDeaths ORDER BY 1,2


-- Total Cases vs Total Deaths
--Likelihood of dying from Covid globally
SELECT location, date, total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as death_percentage
FROM CovidAnalysis..CovidDeaths
ORDER BY 1,2
--Likelihood of dying from Covid just in the United States
SELECT location, date, total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as death_percentage
FROM CovidAnalysis..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Total Cases vs Population
SELECT location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as percent_population_infected
FROM CovidAnalysis..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Highest Infection Rates by Country compared to it's Population
Select location, MAX(total_cases) as highest_infection_count, population, MAX((cast(total_cases as int))/cast(population as float))*100 as percent_population_infected
FROM CovidAnalysis..CovidDeaths
GROUP BY location, population 
ORDER BY percent_population_infected desc

--Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count desc


--Broken down by Continent
--Continents with Highest Death Count per Population 
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count desc

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as death_percentage
FROM CovidAnalysis..CovidDeaths
WHERE continent IS NOT NULL 
ORDER By 1,2


--Total Populations vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM CovidAnalysis..CovidDeaths dea
JOIN CovidAnalysis..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Using CTE to perform PARTITION BY calculation from previous query
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidAnalysis..CovidDeaths dea
JOIN CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac
	

--Temp Table for PARTITION BY calculation from previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidAnalysis..CovidDeaths dea
JOIN CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating Views to store data for visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM CovidAnalysis..CovidDeaths dea
JOIN CovidAnalysis..CovidVaccinations vac
	ON dea.location = vac.location and
	dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated